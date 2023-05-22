
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (approximate special functions utils)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; error function
; erf(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get erf for some args
;
; erf(0)    = 0
; erf(NaN)  = NaN
; erf(PInf) = 1
; erf(NInf) = -1

; <- ebx - assign result flag
; <- ecx - updated flags

macro @@erf.arg.sse
{
$asprocf @@erf.arg

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
        cmp     ecx, 1023-26
        jb     .eps                             ; x.exp < -26

        xmovsd  xmm5, ??.SD_ferf_max_arg
        comisd  xmm0, xmm5
        jae    .max

        xmovsd  xmm5, ??.SD_ferf_min_arg
        comisd  xmm0, xmm5
        ja     .return

   .min:                                        ; x <= min_arg
   .NInf:                                       ; x = Negative Infinity
        xmovsd  xmm0, SIC_AX.m1.0               ; f(x) = -1.0
        mov     cx, 0x8000
        jmp    .assign

   .max:                                        ; x >= max_arg
   .PInf:                                       ; x = Positive Infinity
        xmovsd  xmm0, SIC_AX.1.0                ; f(x) = 1.0
        mov     cx, 0x0000
        jmp    .assign

   .eps:                                        ; erf(x) = (2/sqrt(pi))*x
        xmovsd  xmm5, SIC_AX.2D.SQRT.PI
        mulsd   xmm0, xmm5
;       and     cx, 0x8000
;       jmp    .assign

   .Zero:                                       ; x = 0
;       jmp    .assign

   .assign:
        xor     ebx, ebx

   .return:
        retn
$endp
}

macro @@erf.arg.fpu
{
$asprocf @@erf.arg

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
        cmp     ecx, 1023-26
        jb     .eps                             ; x.exp < -26

        fldq    ??.SD_ferf_max_arg
        fcomp                                   ; compare max_arg to x
        fnjle  .max                             ; jump if x >= max_arg (max_arg <= x)

        fldq    ??.SD_ferf_min_arg
        fcomp                                   ; compare min_arg to x
        fnjl   .return                          ; jump if x > min_arg (min_arg < x)

   .min:                                        ; x <= min_arg
   .NInf:                                       ; x = Negative Infinity
        fstp    st0                             ; f(x) = -1.0
        fld1
        fchs
        mov     cx, 0x8000
        jmp    .assign

   .max:                                        ; x >= max_arg
   .PInf:                                       ; x = Positive Infinity
        fstp    st0                             ; f(x) = 1.0
        fld1
        mov     cx, 0x0000
        jmp    .assign

   .eps:                                        ; erf(x) = (2/sqrt(pi))*x
        fmulq   SIC_AX.2D.SQRT.PI
;       and     cx, 0x8000
;       jmp    .assign

   .Zero:                                       ; x = 0
;       jmp    .assign

   .assign:
        xor     ebx, ebx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@erf.arg.sse
$else
  @@erf.arg.fpu
$end

; ------------------------------------------------------------------------------

; complementary error function
; erfc(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get erfc for some args
;
; erfc(0)    = 1
; erfc(NaN)  = NaN
; erfc(PInf) = 0
; erfc(NInf) = 2

; <- ebx - assign result flag
; <- ecx - updated flags

macro @@erfc.arg.sse
{
$asprocf @@erfc.arg

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
        cmp     ecx, 1023-19
        jb     .eps                             ; x.exp < -19

        xmovsd  xmm5, ??.SD_ferfc_max_arg
        comisd  xmm0, xmm5
        jae    .max

        xmovsd  xmm5, ??.SD_ferfc_min_arg
        comisd  xmm0, xmm5
        ja     .return

   .min:                                        ; x <= min_arg
   .NInf:                                       ; x = Negative Infinity
        xmovsd  xmm0, SIC_AX.2.0                ; f(x) = 2.0
        mov     cx, 0x0000
        jmp    .assign

   .max:                                        ; x >= max_arg
   .PInf:                                       ; x = Positive Infinity
        xorpd   xmm0, xmm0                      ; f(x) = 0.0
        mov     cx, 0x0001
        jmp    .assign

   .eps:                                        ; erf(x) = 1-(2/sqrt(pi))*x
        xmovsd  xmm5, SIC_AX.2D.SQRT.PI
        mulsd   xmm5, xmm0
        xmovsd  xmm0, SIC_AX.1.0
        subsd   xmm0, xmm5
        mov     cx, 0x0000
        jmp    .assign

   .Zero:                                       ; x = 0
        xmovsd  xmm0, SIC_AX.1.0                ; f(x) = 1.0
        mov     cx, 0x0000
;       jmp    .assign

   .assign:
        xor     ebx, ebx

   .return:
        retn
$endp
}

macro @@erfc.arg.fpu
{
$asprocf @@erfc.arg

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
        cmp     ecx, 1023-19
        jb     .eps                             ; x.exp < -19

        fldq    ??.SD_ferfc_max_arg
        fcomp                                   ; compare max_arg to x
        fnjle  .max                             ; jump if x >= max_arg (max_arg <= x)

        fldq    ??.SD_ferfc_min_arg
        fcomp                                   ; compare min_arg to x
        fnjl   .return                          ; jump if x > min_arg (min_arg < x)

   .min:                                        ; x <= min_arg
   .NInf:                                       ; x = Negative Infinity
        fstp    st0                             ; f(x) = 2.0
        fldq    SIC_AX.2.0
        mov     cx, 0x0000
        jmp    .assign

   .max:                                        ; x >= max_arg
   .PInf:                                       ; x = Positive Infinity
        fstp    st0                             ; f(x) = 0.0
        fldz
        mov     cx, 0x0001
        jmp    .assign

   .eps:                                        ; erf(x) = 1-(2/sqrt(pi))*x
        fmulq   SIC_AX.2D.SQRT.PI
        fld1
        fsubrp
        mov     cx, 0x0000
        jmp    .assign

   .Zero:                                       ; x = 0
        fstp    st0                             ; f(x) = 1.0
        fld1
        mov     cx, 0x0000
;       jmp    .assign

   .assign:
        xor     ebx, ebx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@erfc.arg.sse
$else
  @@erfc.arg.fpu
$end

; ------------------------------------------------------------------------------

; normal distribution function
; ndtr(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get ndtr for some args
;
; ndtr(0)    = 0.5
; ndtr(NaN)  = NaN
; ndtr(PInf) = 1
; ndtr(NInf) = 0

; <- ebx - assign result flag
; <- ecx - updated flags

macro @@ndtr.arg.sse
{
$asprocf @@ndtr.arg

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
        cmp     ecx, 1023-54
        jb     .eps                             ; x.exp < -54

        xmovsd  xmm5, ??.SD_fndtr_max_arg
        comisd  xmm0, xmm5
        jae    .max

        xmovsd  xmm5, ??.SD_fndtr_min_arg
        comisd  xmm0, xmm5
        ja     .return

   .min:                                        ; x <= min_arg
   .NInf:                                       ; x = Negative Infinity
        xorpd   xmm0, xmm0                      ; f(x) = 0.0
        mov     cx, 0x0001
        jmp    .assign

   .max:                                        ; x >= max_arg
   .PInf:                                       ; x = Positive Infinity
        xmovsd  xmm0, SIC_AX.1.0                ; f(x) = 1.0
        mov     cx, 0x0000
        jmp    .assign

   .eps:
   .Zero:                                       ; x = 0
        xmovsd  xmm0, SIC_AX.0.5                ; f(x) = 0.5
        mov     cx, 0x0000
;       jmp    .assign

   .assign:
        xor     ebx, ebx

   .return:
        retn
$endp
}

macro @@ndtr.arg.fpu
{
$asprocf @@ndtr.arg

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
        cmp     ecx, 1023-54
        jb     .eps                             ; x.exp < -54

        fldq    ??.SD_fndtr_max_arg
        fcomp                                   ; compare max_arg to x
        fnjle  .max                             ; jump if x >= max_arg (max_arg <= x)

        fldq    ??.SD_fndtr_min_arg
        fcomp                                   ; compare min_arg to x
        fnjl   .return                          ; jump if x > min_arg (min_arg < x)

   .min:                                        ; x <= min_arg
   .NInf:                                       ; x = Negative Infinity
        fstp    st0                             ; f(x) = 0.0
        fldz
        mov     cx, 0x0001
        jmp    .assign

   .max:                                        ; x >= max_arg
   .PInf:                                       ; x = Positive Infinity
        fstp    st0                             ; f(x) = 1.0
        fld1
        mov     cx, 0x0000
        jmp    .assign

   .eps:
   .Zero:                                       ; x = 0
        fstp    st0                             ; f(x) = 0.5
        fldq    SIC_AX.0.5
        mov     cx, 0x0000
;       jmp    .assign

   .assign:
        xor     ebx, ebx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@ndtr.arg.sse
$else
  @@ndtr.arg.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; inverse of normal distribution function
; ndtri(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get ndtri for some args
;
; ndtri(+0)   = NInf
; ndtri(-0)   = NInf
; ndtri(<0)   = NaN
; ndtri(NaN)  = NaN
; ndtri(PInf) = NaN
; ndtri(NInf) = NaN
;
; ndtri(=1)   = PInf
; ndtri(>1)   = NaN

; <- ebx - assign result flag
; <- ecx - updated flags

macro @@ndtri.arg.sse
{
$asprocf @@ndtri.arg

        @@.xmm0.flags.ecx                       ; ecx = flags
        test    cx, 0x8007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x8000                      ; test sign flag
        jnz    .assign.NaN
        test    cx, 0x0002                      ; test infinity flag
        jnz    .PInf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        xmovsd  xmm5, SIC_AX.1.0
        comisd  xmm0, xmm5                      ; compare x to 1
        jb     .return                          ; jump if x < 1
        ja     .assign.NaN                      ; jump if x > 1

   .EQ.1:                                       ; x = 1
        xmovsd  xmm0, SIC_AX.PInf               ; f(x) = PInf
        mov     cx, 0x0002
        jmp    .assign

   .NInf:                                       ; x = Negative Infinity
   .PInf:                                       ; x = Positive Infinity
   .assign.NaN:
        xmovsd  xmm0, SIC_AX.NaN                ; f(x) = NaN
        mov     cx, 0x0004
        jmp    .assign

   .Zero:                                       ; x = 0
        xmovsd  xmm0, SIC_AX.NInf               ; f(x) = NInf
        mov     cx, 0x8002
;       jmp    .assign

   .assign:
        xor     ebx, ebx

   .return:
        retn
$endp
}

macro @@ndtri.arg.fpu
{
$asprocf @@ndtri.arg

        @@.st0.flags.ecx                        ; ecx = flags
        test    cx, 0x8007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x8000                      ; test sign flag
        jnz    .assign.NaN
        test    cx, 0x0002                      ; test infinity flag
        jnz    .PInf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        fld1
        fcomp                                   ; compare 1 to x
        fnstsw  ax
        sahf
        ja     .return                          ; jump if x < 1 (1 > x)
        jb     .assign.NaN                      ; jump if x > 1 (1 < x)
;       fnjg   .return                          ; jump if x < 1 (1 > x)
;       fnjl   .assign.NaN                      ; jump if x > 1 (1 < x)

   .EQ.1:                                       ; x = 1
        fstp    st0                             ; f(x) = PInf
        fldq    SIC_AX.PInf
        mov     cx, 0x0002
        jmp    .assign

   .NInf:                                       ; x = Negative Infinity
   .PInf:                                       ; x = Positive Infinity
   .assign.NaN:
        fstp    st0                             ; f(x) = NaN
        fldq    SIC_AX.NaN
        mov     cx, 0x0004
        jmp    .assign

   .Zero:                                       ; x = 0
        fstp    st0                             ; f(x) = NInf
        fldq    SIC_AX.NInf
        mov     cx, 0x8002
;       jmp    .assign

   .assign:
        xor     ebx, ebx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@ndtri.arg.sse
$else
  @@ndtri.arg.fpu
$end

; ------------------------------------------------------------------------------

; inverse error function
; erfi(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get erfi for some args
;
; erfi(+0)   = +0
; erfi(-0)   = -0
; erfi(NaN)  = NaN
; erfi(PInf) = NaN
; erfi(NInf) = NaN
;
; erfi(+1)   = PInf
; erfi(-1)   = NInf
; erfi(>+1)  = NaN
; erfi(<-1)  = NaN

; <- ebx - assign result flag
; <- ecx - updated flags

macro @@erfi.arg.sse
{
$asprocf @@erfi.arg

        @@.xmm0.flags.ecx                       ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .assign
        test    cx, 0x0002                      ; test infinity flag
        jnz    .Inf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        xmovsd  xmm5, SIC_AX.1.0
        comisd  xmm0, xmm5                      ; compare x to 1
        jb     .LT.1                            ; jump if x < 1
        ja     .assign.NaN                      ; jump if x > 1

   .EQ.1:                                       ; x = 1
        xmovsd  xmm0, SIC_AX.PInf               ; f(x) = PInf
        mov     cx, 0x0002
        jmp    .assign

   .LT.1:                                       ; x < 1
        xmovsd  xmm5, SIC_AX.m1.0
        comisd  xmm0, xmm5                      ; compare x to -1
        ja     .return                          ; jump if x > -1
        jb     .assign.NaN                      ; jump if x < -1

   .EQ.m1:                                      ; x = -1
        xmovsd  xmm0, SIC_AX.NInf               ; f(x) = NInf
        mov     cx, 0x8002
        jmp    .assign

   .Inf:                                        ; x = Infinity
   .assign.NaN:
        xmovsd  xmm0, SIC_AX.NaN                ; f(x) = NaN
        mov     cx, 0x0004
;       jmp    .assign

   .assign:
        xor     ebx, ebx

   .return:
        retn
$endp
}

macro @@erfi.arg.fpu
{
$asprocf @@erfi.arg

        @@.st0.flags.ecx                        ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .assign
        test    cx, 0x0002                      ; test infinity flag
        jnz    .Inf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        fld1
        fcomp                                   ; compare 1 to x
        fnstsw  ax
        sahf
        ja     .LT.1                            ; jump if x < 1 (1 > x)
        jb     .assign.NaN                      ; jump if x > 1 (1 < x)
;       fnjg   .LT.1                            ; jump if x < 1 (1 > x)
;       fnjl   .assign.NaN                      ; jump if x > 1 (1 < x)

   .EQ.1:                                       ; x = 1
        fstp    st0                             ; f(x) = PInf
        fldq    SIC_AX.PInf
        mov     cx, 0x0002
        jmp    .assign

   .LT.1:                                       ; x < 1
        fldq    SIC_AX.m1.0
        fcomp                                   ; compare -1 to x
        fnstsw  ax
        sahf
        jb     .return                          ; jump if x > -1 (-1 < x)
        ja     .assign.NaN                      ; jump if x < -1 (-1 > x)
;       fnjl   .return                          ; jump if x > -1 (-1 < x)
;       fnjg   .assign.NaN                      ; jump if x < -1 (-1 > x)

   .EQ.m1:                                      ; x = -1
        fstp    st0                             ; f(x) = NInf
        fldq    SIC_AX.NInf
        mov     cx, 0x8002
        jmp    .assign

   .Inf:                                        ; x = Infinity
   .assign.NaN:
        fstp    st0                             ; f(x) = NaN
        fldq    SIC_AX.NaN
        mov     cx, 0x0004
;       jmp    .assign

   .assign:
        xor     ebx, ebx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@erfi.arg.sse
$else
  @@erfi.arg.fpu
$end

; ------------------------------------------------------------------------------

; inverse complementary error function
; erfci(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get erfci for some args
;
; erfci(+0)   = PInf
; erfci(-0)   = PInf
; erfci(<-0)  = NaN
; erfci(NaN)  = NaN
; erfci(PInf) = NaN
; erfci(NInf) = NaN
;
; erfci(+2)   = NInf
; erfci(>+2)  = NaN

; <- ebx - assign result flag
; <- ecx - updated flags

macro @@erfci.arg.sse
{
$asprocf @@erfci.arg

        @@.xmm0.flags.ecx                       ; ecx = flags
        test    cx, 0x8007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x8000                      ; test sign flag
        jnz    .assign.NaN
        test    cx, 0x0002                      ; test infinity flag
        jnz    .Inf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        xmovsd  xmm5, SIC_AX.2.0
        comisd  xmm0, xmm5                      ; compare x to 2
        jb     .return                          ; jump if x < 2
        ja     .assign.NaN                      ; jump if x > 2

   .EQ.2:                                       ; x = 2
        xmovsd  xmm0, SIC_AX.NInf               ; f(x) = NInf
        mov     cx, 0x8002
        jmp    .assign

   .Inf:                                        ; x = Infinity
   .assign.NaN:
        xmovsd  xmm0, SIC_AX.NaN                ; f(x) = NaN
        mov     cx, 0x0004
        jmp    .assign

   .Zero:                                       ; x = 0
        xmovsd  xmm0, SIC_AX.PInf               ; f(x) = PInf
        mov     cx, 0x0002
;       jmp    .assign

   .assign:
        xor     ebx, ebx

   .return:
        retn
$endp
}

macro @@erfci.arg.fpu
{
$asprocf @@erfci.arg

        @@.st0.flags.ecx                        ; ecx = flags
        test    cx, 0x8007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x8000                      ; test sign flag
        jnz    .assign.NaN
        test    cx, 0x0002                      ; test infinity flag
        jnz    .Inf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        fldq    SIC_AX.2.0
        fcomp                                   ; compare 2 to x
        fnstsw  ax
        sahf
        ja     .return                          ; jump if x < 2 (2 > x)
        jb     .assign.NaN                      ; jump if x > 2 (2 < x)
;       fnjg   .return                          ; jump if x < 2 (2 > x)
;       fnjl   .assign.NaN                      ; jump if x > 2 (2 < x)

   .EQ.2:                                       ; x = 2
        fstp    st0                             ; f(x) = NInf
        fldq    SIC_AX.NInf
        mov     cx, 0x8002
        jmp    .assign

   .Inf:                                        ; x = Infinity
   .assign.NaN:
        fstp    st0                             ; f(x) = NaN
        fldq    SIC_AX.NaN
        mov     cx, 0x0004
        jmp    .assign

   .Zero:                                       ; x = 0
        fstp    st0                             ; f(x) = PInf
        fldq    SIC_AX.PInf
        mov     cx, 0x0002
;       jmp    .assign

   .assign:
        xor     ebx, ebx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@erfci.arg.sse
$else
  @@erfci.arg.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; gamma function
; tgamma(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get gamma for some args
;
; tgamma(+0)   = PInf
; tgamma(-0)   = NInf
; tgamma(NaN)  = NaN
; tgamma(PInf) = PInf
; tgamma(NInf) = NaN
;
; tgamma(-int) = NaN

; <- ebx - assign result flag
; <- ecx - updated flags

; x < 0
; <- edi - sign bit (0 - positive, 1 - negative)
; <- xmm0 - x
; <- xmm3 - frac(x)
macro @@tgamma.arg.sse
{
        local   @mem
        @mem    EQU esp - 64

$asprocf @@tgamma.arg

        xor     edi, edi

        @@.xmm0.flags.ecx                       ; ecx = flags
        test    cx, 0x8007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        cmp     cx, 0x0002                      ; is positive infinity?
        je     .assign                          ; f(PInf) = PInf
        cmp     cx, 0x8002                      ; is negative infinity?
        je     .NInf
        test    cx, 0x8000                      ; test sign flag
        jnz    .LT.0
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
   .test.max_arg:
        xmovsd  xmm5, ??.SD_ftgamma_max_arg
        comisd  xmm0, xmm5                      ; compare x to max_arg
        jb     .return                          ; jump if x < max_arg

   .max:                                        ; x >= max_arg
        xmovsd  xmm0, SIC_AX.PInf               ; f(x) = PInf
        mov     cx, 0x0002
        jmp    .assign

   .LT.0:                                       ; x < 0
        xmovx   xmm2, xmm0                      ; xmm2 = x
        xfracsd xmm3, xmm0                      ; xmm3 = frac(x)
        xorpd   xmm5, xmm5
        ucomisd xmm3, xmm5                      ; compare frac(x) to 0
        jnz    .LT.0.NotInt
        jp     .LT.0.NotInt

   .LT.0.Int:
        xmovsd  xmm0, SIC_AX.NaN                ; f(x) = NaN
        mov     cx, 0x0024                      ; 0x0020 - negative integer flag
        jmp    .assign

   .LT.0.NotInt:
        subsd   xmm2, xmm3                      ; xmm2 = int(x)
        @@.xmm2.int.flags.edi                   ; edi = integer flags
        dec     edi
        and     edi, 1

   .LT.0.NotInt.test.min_arg:
        xmovsd  xmm5, ??.SD_ftgamma_min_arg
        comisd  xmm0, xmm5                      ; compare x to min_arg
        ja     .return                          ; jump if x > min_arg

   .LT.0.NotInt.min:                            ; x <= min_arg
        xorpd   xmm0, xmm0                      ; f(x) = +0.0
        mov     cx, 0x0001
        test    edi, 1
        jz     .assign
   .LT.0.NotInt.min.LT.0.0:
        @@.chs  xmm0                            ; f(x) = -0.0
        mov     cx, 0x8001
        jmp    .assign

   .NInf:                                       ; x = Negative Infinity
        xmovsd  xmm0, SIC_AX.NaN                ; f(x) = NaN
        mov     cx, 0x0004
        jmp    .assign

   .Zero:                                       ; x = 0
        test    cx, 0x8000                      ; test sign flag
        jz     .PZero
   .NZero:                                      ; x = -0
        xmovsd  xmm0, SIC_AX.NInf               ; f(x) = NInf
        mov     cx, 0x8002
        mov     edi, 1                          ; set negative result bit
        jmp    .assign
   .PZero:                                      ; x = +0
        xmovsd  xmm0, SIC_AX.PInf               ; f(x) = PInf
        mov     cx, 0x0002
;       jmp    .assign

   .assign:
        xor     ebx, ebx

   .return:
        retn
$endp
}

; x < 0
; <- edi - sign bit (0 - positive, 1 - negative)
; <- st0 - x
; <- st1 - frac(x)
macro @@tgamma.arg.fpu
{
        local   @mem
        @mem    EQU esp - 64

$asprocf @@tgamma.arg

        xor     edi, edi

        @@.st0.flags.ecx                        ; ecx = flags
        test    cx, 0x8007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        cmp     cx, 0x0002                      ; is positive infinity?
        je     .assign                          ; f(PInf) = PInf
        cmp     cx, 0x8002                      ; is negative infinity?
        je     .NInf
        test    cx, 0x8000                      ; test sign flag
        jnz    .LT.0
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
   .test.max_arg:
        fldq    ??.SD_ftgamma_max_arg
        fcomp                                   ; compare max_arg to x
        fnjg   .return                          ; jump if x < max_arg (max_arg > x)

   .max:                                        ; x >= max_arg
        fstp    st0                             ; f(x) = PInf
        fldq    SIC_AX.PInf
        mov     cx, 0x0002
        jmp    .assign

   .LT.0:                                       ; x < 0
        fld     st0
        fld     st0                             ; st0 = x       | st1 = x       | st2 = x
        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions
        frndint                                 ; st0 = int(x)  | st1 = x       | st2 = x
        @@.fpu.cw.restore                       ; restore control word
        fxch                                    ; st0 = x       | st1 = int(x)  | st2 = x
        fsub    st0, st1                        ; st0 = frac(x) | st1 = int(x)  | st2 = x
        ftst                                    ; compare frac(x) to 0
        fnjnz  .LT.0.NotInt

   .LT.0.Int:
        fstp    st0                             ; f(x) = NaN
        fstp    st0
        fstp    st0
        fldq    SIC_AX.NaN
        mov     cx, 0x0024                      ; 0x0020 - negative integer flag
        jmp    .assign

   .LT.0.NotInt:
        fxch                                    ; st0 = int(x)  | st1 = frac(x) | st2 = x
        @@.st0.int.flags.edi                    ; edi = integer flags
        dec     edi
        and     edi, 1
        fstp    st0
        fxch                                    ; st0 = x       | st1 = frac(x)

   .LT.0.NotInt.test.min_arg:
        fldq    ??.SD_ftgamma_min_arg
        fcomp                                   ; compare min_arg to x
        fnjl   .return                          ; jump if x > min_arg (min_arg < x)

   .LT.0.NotInt.min:                            ; x <= min_arg
        fstp    st0                             ; f(x) = +0.0
        fstp    st0
        fldz
        mov     cx, 0x0001
        test    edi, 1
        jz     .assign
   .LT.0.NotInt.min.LT.0.0:
        fchs                                    ; f(x) = -0.0
        mov     cx, 0x8001
        jmp    .assign

   .NInf:                                       ; x = Negative Infinity
        fstp    st0                             ; f(x) = NaN
        fldq    SIC_AX.NaN
        mov     cx, 0x0004
        jmp    .assign

   .Zero:                                       ; x = 0
        test    cx, 0x8000                      ; test sign flag
        jz     .PZero
   .NZero:                                      ; x = -0
        fstp    st0                             ; f(x) = NInf
        fldq    SIC_AX.NInf
        mov     cx, 0x8002
        mov     edi, 1                          ; set negative result bit
        jmp    .assign
   .PZero:                                      ; x = +0
        fstp    st0                             ; f(x) = PInf
        fldq    SIC_AX.PInf
        mov     cx, 0x0002
;       jmp    .assign

   .assign:
        xor     ebx, ebx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@tgamma.arg.sse
$else
  @@tgamma.arg.fpu
$end

; ------------------------------------------------------------------------------

; natural logarithm of the absolute value of gamma function
; lgamma(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get lgamma for some args
;
; lgamma(+0)   = PInf
; lgamma(-0)   = PInf
; lgamma(NaN)  = NaN
; lgamma(PInf) = PInf
; lgamma(NInf) = NaN
;
; lgamma(-int) = PInf

; <- ebx - assign result flag
; <- ecx - updated flags

; x < 0
; <- edi - sign bit (0 - positive, 1 - negative)
; <- xmm0 - x
; <- xmm3 - frac(x)
macro @@lgamma.arg.sse
{
        local   @mem
        @mem    EQU esp - 64

$asprocf @@lgamma.arg

        xor     edi, edi

        @@.xmm0.flags.ecx                       ; ecx = flags
        test    cx, 0x8007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x0002                      ; test infinity flag
        jnz    .Inf
        test    cx, 0x8000                      ; test sign flag
        jnz    .LT.0
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
   .test.max_arg:
        xmovsd  xmm5, ??.SD_flgamma_max_arg
        comisd  xmm0, xmm5                      ; compare x to max_arg
        jb     .return                          ; jump if x < max_arg

   .max:                                        ; x >= max_arg
        xmovsd  xmm0, SIC_AX.PInf               ; f(x) = PInf
        mov     cx, 0x0002
        jmp    .assign

   .LT.0:                                       ; x < 0
        xmovx   xmm2, xmm0                      ; xmm2 = x
        xfracsd xmm3, xmm0                      ; xmm3 = frac(x)
        xorpd   xmm5, xmm5
        ucomisd xmm3, xmm5                      ; compare frac(x) to 0
        jnz    .LT.0.NotInt
        jp     .LT.0.NotInt

   .LT.0.Int:
        xmovsd  xmm0, SIC_AX.PInf               ; f(x) = PInf
        mov     cx, 0x0022                      ; 0x0020 - negative integer flag
        jmp    .assign

   .LT.0.NotInt:
        subsd   xmm2, xmm3                      ; xmm2 = int(x)
        @@.xmm2.int.flags.edi                   ; edi = integer flags
        dec     edi
        and     edi, 1

   .LT.0.NotInt.test.min_arg:
        xmovsd  xmm5, ??.SD_flgamma_min_arg
        comisd  xmm0, xmm5                      ; compare x to min_arg
        ja     .return                          ; jump if x > min_arg

   .LT.0.NotInt.min:                            ; x <= min_arg
        test    edi, 1
        jz     .LT.0.NotInt.min.GE.0.0
   .LT.0.NotInt.min.LT.0.0:
        xmovsd  xmm0, SIC_AX.NaN                ; f(x) = NaN
        mov     cx, 0x0004
        jmp    .assign
   .LT.0.NotInt.min.GE.0.0:
        xmovsd  xmm0, SIC_AX.NInf               ; f(x) = NInf
        mov     cx, 0x8002
        jmp    .assign

   .Zero:                                       ; x = 0
   .Inf:                                        ; x = Infinity
        xmovsd  xmm0, SIC_AX.PInf               ; f(x) = PInf
        mov     cx, 0x0002
;       jmp    .assign

   .assign:
        xor     ebx, ebx

   .return:
        retn
$endp
}

; x < 0
; <- edi - sign bit (0 - positive, 1 - negative)
; <- st0 - x
; <- st1 - frac(x)
macro @@lgamma.arg.fpu
{
        local   @mem
        @mem    EQU esp - 64

$asprocf @@lgamma.arg

        xor     edi, edi

        @@.st0.flags.ecx                        ; ecx = flags
        test    cx, 0x8007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x0002                      ; test infinity flag
        jnz    .Inf
        test    cx, 0x8000                      ; test sign flag
        jnz    .LT.0
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
   .test.max_arg:
        fldq    ??.SD_flgamma_max_arg
        fcomp                                   ; compare max_arg to x
        fnjg   .return                          ; jump if x < max_arg (max_arg > x)

   .max:                                        ; x >= max_arg
        fstp    st0                             ; f(x) = PInf
        fldq    SIC_AX.PInf
        mov     cx, 0x0002
        jmp    .assign

   .LT.0:                                       ; x < 0
        fld     st0
        fld     st0                             ; st0 = x       | st1 = x       | st2 = x
        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions
        frndint                                 ; st0 = int(x)  | st1 = x       | st2 = x
        @@.fpu.cw.restore                       ; restore control word
        fxch                                    ; st0 = x       | st1 = int(x)  | st2 = x
        fsub    st0, st1                        ; st0 = frac(x) | st1 = int(x)  | st2 = x
        ftst                                    ; compare frac(x) to 0
        fnjnz  .LT.0.NotInt

   .LT.0.Int:
        fstp    st0                             ; f(x) = NaN
        fstp    st0
        fstp    st0
        fldq    SIC_AX.NaN
        mov     cx, 0x0024                      ; 0x0020 - negative integer flag
        jmp    .assign

   .LT.0.NotInt:
        fxch                                    ; st0 = int(x)  | st1 = frac(x) | st2 = x
        @@.st0.int.flags.edi                    ; edi = integer flags
        dec     edi
        and     edi, 1
        fstp    st0
        fxch                                    ; st0 = x       | st1 = frac(x)

   .LT.0.NotInt.test.min_arg:
        fldq    ??.SD_flgamma_min_arg
        fcomp                                   ; compare min_arg to x
        fnjl   .return                          ; jump if x > min_arg (min_arg < x)

   .LT.0.NotInt.min:                            ; x <= min_arg
        fstp    st0
        fstp    st0
        test    edi, 1
        jz     .LT.0.NotInt.min.GE.0.0
   .LT.0.NotInt.min.LT.0.0:
        fldq    SIC_AX.NaN                      ; f(x) = NaN
        mov     cx, 0x0004
        jmp    .assign
   .LT.0.NotInt.min.GE.0.0:
        fldq    SIC_AX.NInf                     ; f(x) = NInf
        mov     cx, 0x8002
        jmp    .assign

   .Zero:                                       ; x = 0
   .Inf:                                        ; x = Infinity
        fstp    st0                             ; f(x) = PInf
        fldq    SIC_AX.PInf
        mov     cx, 0x0002
;       jmp    .assign

   .assign:
        xor     ebx, ebx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@lgamma.arg.sse
$else
  @@lgamma.arg.fpu
$end

; ------------------------------------------------------------------------------

; reciprocal gamma function
; rgamma(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get rgamma for some args
;
; rgamma(+0)   = +0
; rgamma(-0)   = -0
; rgamma(NaN)  = NaN
; rgamma(PInf) = 0
; rgamma(NInf) = NaN
;
; rgamma(-int) = 0

; <- ebx - assign result flag
; <- ecx - updated flags

; x < 0
; <- edi - sign bit (0 - positive, 1 - negative)
; <- xmm0 - x
; <- xmm3 - frac(x)
macro @@rgamma.arg.sse
{
        local   @mem
        @mem    EQU esp - 64

$asprocf @@rgamma.arg

        xor     edi, edi

        @@.xmm0.flags.ecx                       ; ecx = flags
        test    cx, 0x8007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        cmp     cx, 0x0002                      ; is positive infinity?
        je     .PInf
        cmp     cx, 0x8002                      ; is negative infinity?
        je     .NInf
        test    cx, 0x8000                      ; test sign flag
        jnz    .LT.0
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
   .test.max_arg:
        xmovsd  xmm5, ??.SD_frgamma_max_arg
        comisd  xmm0, xmm5                      ; compare x to max_arg
        jb     .return                          ; jump if x < max_arg

   .max:                                        ; x >= max_arg
        xorpd   xmm0, xmm0                      ; f(x) = 0.0
        mov     cx, 0x0001
        jmp    .assign

   .LT.0:                                       ; x < 0
        xmovx   xmm2, xmm0                      ; xmm2 = x
        xfracsd xmm3, xmm0                      ; xmm3 = frac(x)
        xorpd   xmm5, xmm5
        ucomisd xmm3, xmm5                      ; compare frac(x) to 0
        jnz    .LT.0.NotInt
        jp     .LT.0.NotInt

   .LT.0.Int:
        xorpd   xmm0, xmm0                      ; f(x) = 0.0
        mov     cx, 0x0021                      ; 0x0020 - negative integer flag
        jmp    .assign

   .LT.0.NotInt:
        subsd   xmm2, xmm3                      ; xmm2 = int(x)
        @@.xmm2.int.flags.edi                   ; edi = integer flags
        dec     edi
        and     edi, 1

   .LT.0.NotInt.test.min_arg:
        xmovsd  xmm5, ??.SD_frgamma_min_arg
        comisd  xmm0, xmm5                      ; compare x to min_arg
        ja     .return                          ; jump if x > min_arg

   .LT.0.NotInt.min:                            ; x <= min_arg
        test    edi, 1
        jz     .LT.0.NotInt.min.GE.0.0
   .LT.0.NotInt.min.LT.0.0:
        xmovsd  xmm0, SIC_AX.NInf               ; f(x) = NInf
        mov     cx, 0x8002
        jmp    .assign
   .LT.0.NotInt.min.GE.0.0:
        xmovsd  xmm0, SIC_AX.PInf               ; f(x) = PInf
        mov     cx, 0x0002
        jmp    .assign

   .NInf:                                       ; x = Negative Infinity
        xmovsd  xmm0, SIC_AX.NaN                ; f(x) = NaN
        mov     cx, 0x0004
        jmp    .assign

   .PInf:                                       ; x = Positive Infinity
        xorpd   xmm0, xmm0                      ; f(x) = 0.0
        mov     cx, 0x0001
        jmp    .assign

   .Zero:                                       ; x = 0.0
        test    cx, 0x8000                      ; test sign flag
        jz     .assign
   .NZero:                                      ; x = -0.0
        mov     edi, 1                          ; set sign bit
;       jmp    .assign

   .assign:
        xor     ebx, ebx

   .return:
        retn
$endp
}

; x < 0
; <- edi - sign bit (0 - positive, 1 - negative)
; <- st0 - x
; <- st1 - frac(x)
macro @@rgamma.arg.fpu
{
        local   @mem
        @mem    EQU esp - 64

$asprocf @@rgamma.arg

        xor     edi, edi

        @@.st0.flags.ecx                        ; ecx = flags
        test    cx, 0x8007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        cmp     cx, 0x0002                      ; is positive infinity?
        je     .PInf
        cmp     cx, 0x8002                      ; is negative infinity?
        je     .NInf
        test    cx, 0x8000                      ; test sign flag
        jnz    .LT.0
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
   .test.max_arg:
        fldq    ??.SD_frgamma_max_arg
        fcomp                                   ; compare max_arg to x
        fnjg   .return                          ; jump if x < max_arg (max_arg > x)

   .max:                                        ; x >= max_arg
        fstp    st0                             ; f(x) = 0.0
        fldz
        mov     cx, 0x0001
        jmp    .assign

   .LT.0:                                       ; x < 0
        fld     st0
        fld     st0                             ; st0 = x       | st1 = x       | st2 = x
        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions
        frndint                                 ; st0 = int(x)  | st1 = x       | st2 = x
        @@.fpu.cw.restore                       ; restore control word
        fxch                                    ; st0 = x       | st1 = int(x)  | st2 = x
        fsub    st0, st1                        ; st0 = frac(x) | st1 = int(x)  | st2 = x
        ftst                                    ; compare frac(x) to 0
        fnjnz  .LT.0.NotInt

   .LT.0.Int:
        fstp    st0                             ; f(x) = 0.0
        fstp    st0
        fstp    st0
        fldz
        mov     cx, 0x0021                      ; 0x0020 - negative integer flag
        jmp    .assign

   .LT.0.NotInt:
        fxch                                    ; st0 = int(x)  | st1 = frac(x) | st2 = x
        @@.st0.int.flags.edi                    ; edi = integer flags
        dec     edi
        and     edi, 1
        fstp    st0
        fxch                                    ; st0 = x       | st1 = frac(x)

   .LT.0.NotInt.test.min_arg:
        fldq    ??.SD_frgamma_min_arg
        fcomp                                   ; compare min_arg to x
        fnjl   .return                          ; jump if x > min_arg (min_arg < x)

   .LT.0.NotInt.min:                            ; x <= min_arg
        fstp    st0
        fstp    st0
        test    edi, 1
        jz     .LT.0.NotInt.min.GE.0.0
   .LT.0.NotInt.min.LT.0.0:
        fldq    SIC_AX.NInf                     ; f(x) = NInf
        mov     cx, 0x8002
        jmp    .assign
   .LT.0.NotInt.min.GE.0.0:
        fldq    SIC_AX.PInf                     ; f(x) = PInf
        mov     cx, 0x0002
        jmp    .assign

   .NInf:                                       ; x = Negative Infinity
        fstp    st0                             ; f(x) = NaN
        fldq    SIC_AX.NaN
        mov     cx, 0x0004
        jmp    .assign

   .PInf:                                       ; x = Positive Infinity
        fstp    st0                             ; f(x) = 0.0
        fldz
        mov     cx, 0x0001
        jmp    .assign

   .Zero:                                       ; x = 0.0
        test    cx, 0x8000                      ; test sign flag
        jz     .assign
   .NZero:                                      ; x = -0.0
        mov     edi, 1                          ; set sign bit
;       jmp    .assign

   .assign:
        xor     ebx, ebx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@rgamma.arg.sse
$else
  @@rgamma.arg.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; beta function
; beta(x,y)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get beta for some args

; beta(NInf , y) = NaN
; beta(PInf , y) = 0
; beta(0    , y) = PInf
; beta(NaN  , y) = NaN
;
; beta(x , NInf) = NaN
; beta(x , PInf) = 0
; beta(x , 0   ) = PInf
; beta(x , NaN ) = NaN

; ->
; x = xmm0
; y = xmm1

; <- ebx - assign result flag
; <- ecx - updated flags

macro @@.beta.arg.sse
{
$asprocf @@beta.arg

        @@.xmm0.flags.ecx                       ; ecx = x flags
        @@.xmm1.flags.edx                       ; edx = y flags

        test    cx, 0x0007                      ; test x any flag
        jnz    .x.spec
        test    dx, 0x0007                      ; test d any flag
        jnz    .y.spec

   .x.main:
        jmp    .return

   .y.main:
        jmp    .return

   .x.spec:
        cmp     cx, 0x8002                      ; is x negative infinity?
        je     .assign.NaN
        cmp     cx, 0x0002                      ; is x positive infinity?
        je     .assign.Zero
        test    cx, 0x0001                      ; test x zero flag
        jnz    .assign.PInf
        test    cx, 0x0004                      ; test x nan flag
        jz     .return
;       jz     .x.main

   .x.assign.NaN:
        xmovsd  xmm0, SIC_AX.NaN                ; f(x) = NaN
        mov     cx, 0x0004
        jmp    .assign

   .y.spec:
        cmp     dx, 0x8002                      ; is y negative infinity?
        je     .assign.NaN
        cmp     dx, 0x0002                      ; is y positive infinity?
        je     .assign.Zero
        test    dx, 0x0001                      ; test y zero flag
        jnz    .assign.PInf
        test    dx, 0x0004                      ; test y nan flag
        jz     .return
;       jz     .y.main

   .y.assign.NaN:
   .assign.NaN:
        xmovsd  xmm0, SIC_AX.NaN                ; f(x) = NaN
        mov     cx, 0x0004
        jmp    .assign

   .assign.PInf:
        xmovsd  xmm0, SIC_AX.PInf               ; f(x) = PInf
        mov     cx, 0x0002
        jmp    .assign

   .assign.Zero:
        xmovsd  xmm0, SIC_AX.0.0                ; f(x) = 0.0
        mov     cx, 0x0001
;       jmp    .assign

   .assign:
        xor     ebx, ebx

   .return:
        retn
$endp
}

; ->
; x = st1
; y = st0

; <- ebx - assign result flag
; <- ecx - updated flags

macro @@.beta.arg.fpu
{
$asprocf @@beta.arg

        @@.st0.flags.edx                        ; edx = y flags
        fxch
        @@.st0.flags.ecx                        ; ecx = x flags
        fxch

        test    cx, 0x0007                      ; test x any flag
        jnz    .x.spec
        test    dx, 0x0007                      ; test d any flag
        jnz    .y.spec

   .x.main:
        jmp    .return

   .y.main:
        jmp    .return

   .x.spec:
        cmp     cx, 0x8002                      ; is x negative infinity?
        je     .assign.NaN
        cmp     cx, 0x0002                      ; is x positive infinity?
        je     .assign.Zero
        test    cx, 0x0001                      ; test x zero flag
        jnz    .assign.PInf
        test    cx, 0x0004                      ; test x nan flag
        jz     .return
;       jz     .x.main

   .x.assign.NaN:
        fldq    SIC_AX.NaN                      ; f(x) = NaN
        mov     cx, 0x0004
        jmp    .assign

   .y.spec:
        cmp     dx, 0x8002                      ; is y negative infinity?
        je     .assign.NaN
        cmp     dx, 0x0002                      ; is y positive infinity?
        je     .assign.Zero
        test    dx, 0x0001                      ; test y zero flag
        jnz    .assign.PInf
        test    dx, 0x0004                      ; test y nan flag
        jz     .return
;       jz     .y.main

   .y.assign.NaN:
   .assign.NaN:
        fldq    SIC_AX.NaN                      ; f(x) = NaN
        mov     cx, 0x0004
        jmp    .assign

   .assign.PInf:
        fldq    SIC_AX.PInf                     ; f(x) = PInf
        mov     cx, 0x0002
        jmp    .assign

   .assign.Zero:
        fldz                                    ; f(x) = 0.0
        mov     cx, 0x0001
;       jmp    .assign

   .assign:
        fstp    st1
        fstp    st1
        xor     ebx, ebx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@.beta.arg.sse
$else
  @@.beta.arg.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; Fresnel integrals S(x) & C(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get S(x) & C(x) for some args
;
; S(+0)   = +0
; S(-0)   = -0
; S(NaN)  = NaN
; S(PInf) = +0.5
; S(NInf) = -0.5
;
; C(+0)   = 1
; C(-0)   = 1
; C(NaN)  = NaN
; C(PInf) = +0.5
; C(NInf) = -0.5

; <- ebx - assign result flag

macro @@fresnel.arg.sse
{
$asprocf @@fresnel.arg

   .flags:
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
        xmovsd  xmm5, ??.SD_ffresnel_max_arg    ; xmm5 = max_arg = +36974.0
        comisd  xmm0, xmm5
        ja     .max                             ; jump if x > max_arg

;       xmovsd  xmm5, ??.SD_ffresnel_min_arg    ; xmm5 = min_arg = -36974.0
        @@.chs  xmm5
        comisd  xmm0, xmm5
        jae    .return                          ; jump if x >= min_arg

   .min:                                        ; x < min_arg
   .NInf:                                       ; x = Negative Infinity
        xmovsd  xmm0, SIC_AX.m0.5               ; s = -0.5
        movsd   xmm1, xmm0                      ; c = -0.5
        jmp    .assign

   .max:                                        ; x > max_arg
   .PInf:                                       ; x = Positive Infinity
        xmovsd  xmm0, SIC_AX.0.5                ; s = +0.5
        movsd   xmm1, xmm0                      ; c = +0.5
        jmp    .assign

   .NaN:                                        ; x = Not a Number = xmm0
;       xmovx   xmm0, xmm0                      ; s = NaN
        xmovx   xmm1, xmm0                      ; c = NaN
        jmp    .assign

   .Zero:                                       ; x = 0 = xmm0
;       xmovx   xmm0, xmm0                      ; s = 0
        movsd   xmm1, xmm0                      ; c = 0
;       jmp    .assign

   .assign:
        xor     ebx, ebx

   .return:
        retn
$endp
}

macro @@fresnel.arg.fpu
{
$asprocf @@fresnel.arg

   .flags:
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
        fldq    ??.SD_ffresnel_max_arg          ; st0 = max_arg = +36974.0
        fcomp                                   ; compare max_arg to x
        fnjl   .max                             ; jump if x > max_arg (max_arg < x)

        fldq    ??.SD_ffresnel_min_arg          ; st0 = min_arg = -36974.0
        fcomp                                   ; compare min_arg to x
        fnjle  .return                          ; jump if x >= min_arg (min_arg <= x)

   .min:                                        ; x < min_arg
   .NInf:                                       ; x = Negative Infinity
        fstp    st0
        fldq    SIC_AX.m0.5                     ; st0 = -0.5
        fld     st0                             ; st0 = c = -0.5 | st1 = s = -0.5
        jmp    .assign

   .max:                                        ; x > max_arg
   .PInf:                                       ; x = Positive Infinity
        fstp    st0
        fldq    SIC_AX.0.5                      ; st0 = +0.5
        fld     st0                             ; st0 = c = +0.5 | st1 = s = +0.5
        jmp    .assign

   .NaN:                                        ; x = Not a Number = st0
        fld     st0                             ; st0 = c = NaN | st1 = s = NaN
        jmp    .assign

   .Zero:                                       ; x = 0 = st0
        fld     st0                             ; st0 = c = 0 | st1 = s = 0
;       jmp    .assign

   .assign:
        xor     ebx, ebx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fresnel.arg.sse
$else
  @@fresnel.arg.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; Sine and cosine integrals Si(x) & Ci(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get Si(x) & Ci(x) for some args
;
; Si(+0)   = +0
; Si(-0)   = -0
; Si(NaN)  = NaN
; Si(PInf) = +PI/2
; Si(NInf) = -PI/2
;
; Ci(+0)   = NInf
; Ci(-0)   = NInf
; Ci(NaN)  = NaN
; Ci(PInf) = 0
; Ci(NInf) = 0

; <- ebx - assign result flag

macro @@sici.arg.sse
{
        local   @space, @x, @s

        @space  = 2*16                          ; 2 local variables

        @x      EQU esp + 0*16
        @s      EQU esp + 1*16

$asprocf @@sici.arg

   .enter:
        @@.stack.align16.enter
        sub     esp, @space

   .flags:
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
        xmovsd  xmm5, ??.SD_fsici_DP3p          ; xmm5 = +DP3 = +1.0E+9
        comisd  xmm0, xmm5
        ja     .DP3.Pos                         ; jump if x > +DP3

;       xmovsd  xmm5, ??.SD_fsici_DP3n          ; xmm5 = -DP3 = -1.0E+9
        @@.chs  xmm5
        comisd  xmm0, xmm5
        jae    .leave                           ; jump if x >= -DP3

   .DP3.Neg:                                    ; x < -1.0E+9
        ; Si(x) = -PI/2 - cos(x)/x
        ; Ci(x) = sin(x)/x
        xmovsd  xmm2, SIC_AX.1.0
        divsd   xmm2, xmm0                      ; xmm2 = 1/x
        movsd   [@x], xmm0                      ; @x = x
        mov     edx, @@fsin.core
        call    edx
        mulsd   xmm0, xmm2                      ; xmm0 = sin(x)/x
        movsd   [@s], xmm0                      ; @s = sin(x)/x
        movsd   xmm0, [@x]
        mov     edx, @@fcos.core
        call    edx
        mulsd   xmm2, xmm0                      ; xmm2 = cos(x)/x
        xmovsd  xmm0, SIC_AX.mpi2
        subsd   xmm0, xmm2                      ; Si(x) = -PI/2 - cos(x)/x
        movsd   xmm1, [@s]                      ; Ci(x) = sin(x)/x
        jmp    .assign

   .DP3.Pos:                                    ; x > +1.0E+9
        ; Si(x) = PI/2 - cos(x)/x
        ; Ci(x) = sin(x)/x
        xmovsd  xmm2, SIC_AX.1.0
        divsd   xmm2, xmm0                      ; xmm2 = 1/x
        movsd   [@x], xmm0                      ; @x = x
        mov     edx, @@fsin.core
        call    edx
        mulsd   xmm0, xmm2                      ; xmm0 = sin(x)/x
        movsd   [@s], xmm0                      ; @s = sin(x)/x
        movsd   xmm0, [@x]
        mov     edx, @@fcos.core
        call    edx
        mulsd   xmm2, xmm0                      ; xmm2 = cos(x)/x
        xmovsd  xmm0, SIC_AX.pi2
        subsd   xmm0, xmm2                      ; Si(x) = PI/2 - cos(x)/x
        movsd   xmm1, [@s]                      ; Ci(x) = sin(x)/x
        jmp    .assign

   .NInf:                                       ; x = Negative Infinity
        xmovsd  xmm0, SIC_AX.mpi2               ; s = -PI/2
        xorpd   xmm1, xmm1                      ; c = 0
        jmp    .assign

   .PInf:                                       ; x = Positive Infinity
        xmovsd  xmm0, SIC_AX.pi2                ; s = +PI/2
        xorpd   xmm1, xmm1                      ; c = 0
        jmp    .assign

   .NaN:                                        ; x = Not a Number = xmm0
;       xmovx   xmm0, xmm0                      ; s = NaN
        xmovx   xmm1, xmm0                      ; c = NaN
        jmp    .assign

   .Zero:                                       ; x = 0 = xmm0
;       xmovx   xmm0, xmm0                      ; s = 0
        xmovsd  xmm1, SIC_AX.NInf               ; c = NInf
;       jmp    .assign

   .assign:
        xor     ebx, ebx

   .leave:
        add     esp, @space
        @@.stack.align16.leave
   .return:
        retn
$endp
}

macro @@sici.arg.fpu
{
$asprocf @@sici.arg

   .flags:
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
        fldq    ??.SD_fsici_DP3p                ; st0 = +DP3 = +1.0E+9
        fcomp                                   ; compare +DP3 to x
        fnjl   .DP3.Pos                         ; jump if x > +DP3 (+DP3 < x)

        fldq    ??.SD_fsici_DP3n                ; st0 = -DP3 = -1.0E+9
        fcomp                                   ; compare -DP3 to x
        fnjle  .return                          ; jump if x >= -DP3 (-DP3 <= x)

   .DP3.Neg:                                    ; x < -1.0E+9
        ; Si(x) = -PI/2 - cos(x)/x
        ; Ci(x) = sin(x)/x
        fld     st0                             ; st0 = x        | st1 = x
        fld1
        fdivrp                                  ; st0 = 1/x      | st1 = x
        fxch                                    ; st0 = x        | st1 = 1/x
        fld     st0                             ; st0 = x        | st1 = x     | st2 = 1/x
        mov     edx, @@fcos.core
        call    edx                             ; st0 = cos(x)   | st1 = x     | st2 = 1/x
        fmul    st0, st2                        ; st0 = cos(x)/x | st1 = x     | st2 = 1/x
        fsubrq  SIC_AX.mpi2                     ; st0 = Si(x)    | st1 = x     | st2 = 1/x
        fxch                                    ; st0 = x        | st1 = Si(x) | st2 = 1/x
        mov     edx, @@fsin.core
        call    edx                             ; st0 = sin(x)   | st1 = Si(x) | st2 = 1/x
        fmulp   st2, st0                        ; st0 = Si(x)    | st1 = Ci(x)
        fxch                                    ; st0 = Ci(x)    | st1 = Si(x)
        jmp    .assign

   .DP3.Pos:                                    ; x > +1.0E+9
        ; Si(x) = PI/2 - cos(x)/x
        ; Ci(x) = sin(x)/x
        fld     st0                             ; st0 = x        | st1 = x
        fld1
        fdivrp                                  ; st0 = 1/x      | st1 = x
        fxch                                    ; st0 = x        | st1 = 1/x
        fld     st0                             ; st0 = x        | st1 = x     | st2 = 1/x
        mov     edx, @@fcos.core
        call    edx                             ; st0 = cos(x)   | st1 = x     | st2 = 1/x
        fmul    st0, st2                        ; st0 = cos(x)/x | st1 = x     | st2 = 1/x
        fsubrq  SIC_AX.pi2                      ; st0 = Si(x)    | st1 = x     | st2 = 1/x
        fxch                                    ; st0 = x        | st1 = Si(x) | st2 = 1/x
        mov     edx, @@fsin.core
        call    edx                             ; st0 = sin(x)   | st1 = Si(x) | st2 = 1/x
        fmulp   st2, st0                        ; st0 = Si(x)    | st1 = Ci(x)
        fxch                                    ; st0 = Ci(x)    | st1 = Si(x)
        jmp    .assign

   .NInf:                                       ; x = Negative Infinity
        fstp    st0
        fldq    SIC_AX.mpi2                     ; st0 = -PI/2
        fldz                                    ; st0 = c = 0 | st1 = s = -PI/2
        jmp    .assign

   .PInf:                                       ; x = Positive Infinity
        fstp    st0
        fldq    SIC_AX.pi2                      ; st0 = +PI/2
        fldz                                    ; st0 = c = 0 | st1 = s = +PI/2
        jmp    .assign

   .NaN:                                        ; x = Not a Number = st0
        fld     st0                             ; st0 = c = NaN | st1 = s = NaN
        jmp    .assign

   .Zero:                                       ; x = 0 = st0
        fldq    SIC_AX.NInf                     ; st0 = c = NInf | st1 = s = 0
;       jmp    .assign

   .assign:
        xor     ebx, ebx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@sici.arg.sse
$else
  @@sici.arg.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; Hyperbolic sine and cosine integrals Shi(x) & Chi(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get Shi(x) & Chi(x) for some args
;
; Shi(+0)   = +0
; Shi(-0)   = -0
; Shi(NaN)  = NaN
; Shi(PInf) = PInf
; Shi(NInf) = NInf
;
; Chi(+0)   = NInf
; Chi(-0)   = NInf
; Chi(NaN)  = NaN
; Chi(PInf) = PInf
; Chi(NInf) = PInf

; <- ebx - assign result flag

macro @@shichi.arg.sse
{
$asprocf @@shichi.arg

   .flags:
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
        xmovsd  xmm5, ??.SD_fshichi_max_arg     ; xmm5 = max_arg = +88.0
        comisd  xmm0, xmm5
        ja     .max                             ; jump if x > max_arg

;       xmovsd  xmm5, ??.SD_fshichi_min_arg     ; xmm5 = min_arg = -88.0
        @@.chs  xmm5
        comisd  xmm0, xmm5
        jae    .return                          ; jump if x >= min_arg

   .min:                                        ; x < min_arg
        xmovsd  xmm0, SIC_AX.NInf               ; s = NInf
        xmovsd  xmm1, SIC_AX.PInf               ; c = PInf
        jmp    .assign

   .NInf:                                       ; x = Negative Infinity
;       xmovsd  xmm0, SIC_AX.NInf               ; s = NInf
        xmovsd  xmm1, SIC_AX.PInf               ; c = PInf
        jmp    .assign

   .max:                                        ; x > max_arg
        xmovsd  xmm0, SIC_AX.PInf               ; s = PInf
        movsd   xmm1, xmm0                      ; c = PInf
        jmp    .assign

   .PInf:                                       ; x = Positive Infinity
;       xmovsd  xmm0, SIC_AX.PInf               ; s = PInf
        movsd   xmm1, xmm0                      ; c = PInf
        jmp    .assign

   .NaN:                                        ; x = Not a Number = xmm0
;       xmovx   xmm0, xmm0                      ; s = NaN
        xmovx   xmm1, xmm0                      ; c = NaN
        jmp    .assign

   .Zero:                                       ; x = 0 = xmm0
;       xmovx   xmm0, xmm0                      ; s = 0
        xmovsd  xmm1, SIC_AX.NInf               ; c = NInf
;       jmp    .assign

   .assign:
        xor     ebx, ebx

   .return:
        retn
$endp
}

macro @@shichi.arg.fpu
{
$asprocf @@shichi.arg

   .flags:
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
        fldq    ??.SD_fshichi_max_arg           ; st0 = max_arg = +88.0
        fcomp                                   ; compare max_arg to x
        fnjl   .max                             ; jump if x > max_arg (max_arg < x)

        fldq    ??.SD_fshichi_min_arg           ; st0 = min_arg = -88.0
        fcomp                                   ; compare min_arg to x
        fnjle  .return                          ; jump if x >= min_arg (min_arg <= x)

   .min:                                        ; x < min_arg
        fstp    st0
        fldq    SIC_AX.NInf                     ; st0 = NInf
        fldq    SIC_AX.PInf                     ; st0 = c = PInf | st1 = s = NInf
        jmp    .assign

   .NInf:                                       ; x = Negative Infinity = st0
        fldq    SIC_AX.PInf                     ; st0 = c = PInf | st1 = s = NInf
        jmp    .assign

   .max:                                        ; x > max_arg
        fstp    st0
        fldq    SIC_AX.PInf                     ; st0 = PInf
        fld     st0                             ; st0 = c = PInf | st1 = s = PInf
        jmp    .assign

   .PInf:                                       ; x = Positive Infinity = st0
        fld     st0                             ; st0 = c = PInf | st1 = s = PInf
        jmp    .assign

   .NaN:                                        ; x = Not a Number = st0
        fld     st0                             ; st0 = c = NaN | st1 = s = NaN
        jmp    .assign

   .Zero:                                       ; x = 0 = st0
        fldq    SIC_AX.NInf                     ; st0 = c = NInf | st1 = s = 0
;       jmp    .assign

   .assign:
        xor     ebx, ebx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@shichi.arg.sse
$else
  @@shichi.arg.fpu
$end

; ------------------------------------------------------------------------------
