
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (trigonometric functions utils)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; -> xmm0 = x
; <- xmm0 = x mod 2pi

macro @@.xmm0.mod.2pi
{
        xmovsd  xmm5, ??.1D.2pi                 ; xmm5 = 1/2pi = 1/y
        movsd   xmm4, xmm0                      ; xmm4 = x
        mulsd   xmm4, xmm5                      ; xmm4 = x/y
        xintsd  xmm4, xmm4                      ; xmm4 = int(x/y)
        xmovsd  xmm5, ??.2pi                    ; xmm5 = 2pi = y = D
        mulsd   xmm4, xmm5                      ; xmm4 = y*int(x/y)
        subsd   xmm0, xmm4                      ; xmm0 = x - y*int(x/y)
   .mod.range:
        mov     xmm4, xmm0
        @@.abs  xmm4
        comisd  xmm4, xmm5                      ; compare |U mod D| to D
        jb     .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        xorpd   xmm0, xmm0
   .mod.range.out:
}

; ------------------------------------------------------------------------------

; -> xmm0 = x
; <- xmm0 = x mod pi

macro @@.xmm0.mod.pi
{
        xmovsd  xmm5, ??.1D.pi                  ; xmm5 = 1/pi = 1/y
        movsd   xmm4, xmm0                      ; xmm4 = x
        mulsd   xmm4, xmm5                      ; xmm4 = x/y
        xintsd  xmm4, xmm4                      ; xmm4 = int(x/y)
        xmovsd  xmm5, ??.pi                     ; xmm5 = pi = y = D
        mulsd   xmm4, xmm5                      ; xmm4 = y*int(x/y)
        subsd   xmm0, xmm4                      ; xmm0 = x - y*int(x/y)
   .mod.range:
        mov     xmm4, xmm0
        @@.abs  xmm4
        comisd  xmm4, xmm5                      ; compare |U mod D| to D
        jb     .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        xorpd   xmm0, xmm0
   .mod.range.out:
}

; ------------------------------------------------------------------------------

; st0 = st0 mod 2pi

macro @@.st0.mod.2pi
{
        mov     rax, ??.2pi
        fld     qword [rax]                     ; st0 = D = 2pi | st1 = x
        fxch                                    ; st0 = x       | st1 = D
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
}

; ------------------------------------------------------------------------------

; st0 = st0 mod pi

macro @@.st0.mod.pi
{
        mov     rax, ??.pi
        fld     qword [rax]                     ; st0 = D = pi  | st1 = x
        fxch                                    ; st0 = x       | st1 = D
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
}

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; reduce argument for sin(cos) function

macro @@xmm0.sin.cos.core.reduce reg
{
}

macro @@..xmm0.sin.cos.core.reduce reg
{
    if (reg eq)
        mov     rcx, @@.xmm0.sin.cos.core.reduce
        call    rcx
    else
        mov     reg, @@.xmm0.sin.cos.core.reduce
        call    reg
    end if
}

$asproc @@.xmm0.sin.cos.core.reduce

   .main:
        @@.xmm0.mod.2pi
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; reduce argument for sin(cos) function

macro @@st0.sin.cos.core.reduce reg
{
}

macro @@..st0.sin.cos.core.reduce reg
{
    if (reg eq)
        mov     rcx, @@.st0.sin.cos.core.reduce
        call    rcx
    else
        mov     reg, @@.st0.sin.cos.core.reduce
        call    reg
    end if
}

$asproc @@.st0.sin.cos.core.reduce

   .main:
        @@.st0.mod.2pi
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; reduce argument for tan(cotan) function

macro @@xmm0.tan.cotan.core.reduce reg
{
}

macro @@..xmm0.tan.cotan.core.reduce reg
{
    if (reg eq)
        mov     rcx, @@.xmm0.tan.cotan.core.reduce
        call    rcx
    else
        mov     reg, @@.xmm0.tan.cotan.core.reduce
        call    reg
    end if
}

$asproc @@.xmm0.tan.cotan.core.reduce

   .main:
        @@.xmm0.mod.pi
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; reduce argument for tan(cotan) function

macro @@st0.tan.cotan.core.reduce reg
{
}

macro @@..st0.tan.cotan.core.reduce reg
{
    if (reg eq)
        mov     rcx, @@.st0.tan.cotan.core.reduce
        call    rcx
    else
        mov     reg, @@.st0.tan.cotan.core.reduce
        call    reg
    end if
}

$asproc @@.st0.tan.cotan.core.reduce

   .main:
        @@.st0.mod.pi
   .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; sine

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get sin for some args
;
; sin(+0)   = +0
; sin(-0)   = -0
; sin(NaN)  = NaN
; sin(PInf) = +0
; sin(NInf) = -0

; <- rbx - assign result flag

macro @@.sin.arg.sse
{
$asprocf @@.sin.arg

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

   .NInf:                                       ; x = Negative Infinity
        xorpd   xmm0, xmm0
        @@.chs  xmm0                            ; -0.0
        jmp    .assign

   .PInf:                                       ; x = Positive Infinity
        xorpd   xmm0, xmm0                      ; +0.0
;       jmp    .assign

   .Zero:                                       ; x = 0
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

macro @@.sin.arg.fpu
{
$asprocf @@.sin.arg

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

   .NInf:                                       ; x = Negative Infinity
        fstp    st0
        fldz
        fchs                                    ; -0.0
        jmp    .assign

   .PInf:                                       ; x = Positive Infinity
        fstp    st0
        fldz                                    ; +0.0
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
; @@.sin.arg.sse
$else
; @@.sin.arg.fpu
$end

; ------------------------------------------------------------------------------

; cosine

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get cos for some args
;
; cos(+0)   = 1
; cos(-0)   = 1
; cos(NaN)  = NaN
; cos(PInf) = 1
; cos(NInf) = 1

; <- rbx - assign result flag

macro @@.cos.arg.sse
{
$asprocf @@.cos.arg

        @@.xmm0.flags.ecx                       ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .return
;       jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x0002                      ; test infinity flag
        jnz    .Inf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        jmp    .return

   .Inf:                                        ; x = Infinity
        xmovsd  xmm0, SIC_AX.1.0
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

macro @@.cos.arg.fpu
{
$asprocf @@.cos.arg

        @@.st0.flags.ecx                        ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .return
;       jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x0002                      ; test infinity flag
        jnz    .Inf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        jmp    .return

   .Inf:                                        ; x = Infinity
        fstp    st0
        fld1
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
; @@.cos.arg.sse
$else
; @@.cos.arg.fpu
$end

; ------------------------------------------------------------------------------

; sine & cosine

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get sin & cos for some args
;
; sin(+0)   = +0
; sin(-0)   = -0
; sin(NaN)  = NaN
; sin(PInf) = +0
; sin(NInf) = -0
;
; cos(+0)   = 1
; cos(-0)   = 1
; cos(NaN)  = NaN
; cos(PInf) = 1
; cos(NInf) = 1

; <- rbx - assign result flag

macro @@.sincos.arg.sse
{
$asprocf @@.sincos.arg

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
        jnz    .NaN

   .main:
        jmp    .return

   .NInf:                                       ; x = Negative Infinity
        xorpd   xmm0, xmm0
        @@.chs  xmm0                            ; sin = -0.0
        xmovsd  xmm1, SIC_AX.1.0                ; cos = 1.0
        jmp    .assign

   .PInf:                                       ; x = Positive Infinity
        xorpd   xmm0, xmm0                      ; sin = +0.0
        xmovsd  xmm1, SIC_AX.1.0                ; cos = 1.0
        jmp    .assign

   .NaN:                                        ; x = Not a Number
        movsd   xmm1, xmm0
        jmp    .assign

   .Zero:                                       ; x = 0 = xmm0
;       movsd   xmm0, xmm0                      ; sin = 0
        xmovsd  xmm1, SIC_AX.1.0                ; cos = 1
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

macro @@.sincos.arg.fpu
{
$asprocf @@.sincos.arg

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
        jnz    .NaN

   .main:
        jmp    .return

   .NInf:                                       ; x = Negative Infinity
        fstp    st0
        fldz
        fchs
        fld1                                    ; st0 = cos = 1.0  | st1 = sin = -0.0
        jmp    .assign

   .PInf:                                       ; x = Positive Infinity
        fstp    st0
        fldz
        fld1                                    ; st0 = cos = 1.0  | st1 = sin = +0.0
        jmp    .assign

   .NaN:                                        ; x = Not a Number
        fld     st0
        jmp    .assign

   .Zero:                                       ; x = 0 = st0
        fld1                                    ; st0 = cos = 1 | st1 = sin = 0
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

$ifdef _SSEX
; @@.sincos.arg.sse
$else
; @@.sincos.arg.fpu
$end

; ------------------------------------------------------------------------------

; cosine & sine

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get cos & sin for some args
;
; cos(+0)   = 1
; cos(-0)   = 1
; cos(NaN)  = NaN
; cos(PInf) = 1
; cos(NInf) = 1
;
; sin(+0)   = +0
; sin(-0)   = -0
; sin(NaN)  = NaN
; sin(PInf) = +0
; sin(NInf) = -0

; <- rbx - assign result flag

macro @@.cossin.arg.sse
{
$asprocf @@.cossin.arg

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
        jnz    .NaN

   .main:
        jmp    .return

   .NInf:                                       ; x = Negative Infinity
        xmovsd  xmm0, SIC_AX.1.0                ; cos = 1.0
        xorpd   xmm1, xmm1
        @@.chs  xmm1                            ; sin = -0.0
        jmp    .assign

   .PInf:                                       ; x = Positive Infinity
        xmovsd  xmm0, SIC_AX.1.0                ; cos = 1.0
        xorpd   xmm1, xmm1                      ; sin = +0.0
        jmp    .assign

   .NaN:                                        ; x = Not a Number
        movsd   xmm1, xmm0
        jmp    .assign

   .Zero:                                       ; x = 0 = xmm0
        movsd   xmm1, xmm0                      ; sin = 0
        xmovsd  xmm0, SIC_AX.1.0                ; cos = 1
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

macro @@.cossin.arg.fpu
{
$asprocf @@.cossin.arg

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
        jnz    .NaN

   .main:
        jmp    .return

   .NInf:                                       ; x = Negative Infinity
        fstp    st0
        fld1
        fldz
        fchs                                    ; st0 = sin = -0.0 | st1 = cos = 1
        jmp    .assign

   .PInf:                                       ; x = Positive Infinity
        fstp    st0
        fld1
        fldz                                    ; st0 = sin = +0.0 | st1 = cos = 1
        jmp    .assign

   .NaN:                                        ; x = Not a Number
        fld     st0
        jmp    .assign

   .Zero:                                       ; x = 0 = st0
        fld1                                    ; st0 = 1       | st1 = 0
        fxch                                    ; st0 = sin = 0 | st1 = cos = 1
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

$ifdef _SSEX
; @@.cossin.arg.sse
$else
; @@.cossin.arg.fpu
$end

; ------------------------------------------------------------------------------

; secant
; 1 / cosine

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get secant for some args
;
; sec(+0)   = 1
; sec(-0)   = 1
; sec(NaN)  = NaN
; sec(PInf) = 1
; sec(NInf) = 1

; <- rbx - assign result flag

macro @@.sec.arg.sse
{
$asprocf @@.sec.arg

        @@.xmm0.flags.ecx                       ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .return
;       jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x0002                      ; test infinity flag
        jnz    .Inf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        jmp    .return

   .Inf:                                        ; x = Infinity
;       xmovsd  xmm0, SIC_AX.1.0
;       jmp    .assign

   .Zero:                                       ; x = 0
        xmovsd  xmm0, SIC_AX.1.0
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

macro @@.sec.arg.fpu
{
$asprocf @@.sec.arg

        @@.st0.flags.ecx                        ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .return
;       jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x0002                      ; test infinity flag
        jnz    .Inf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        jmp    .return

   .Inf:                                        ; x = Infinity
;       fstp    st0
;       fld1
;       jmp    .assign

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
; @@.sec.arg.sse
$else
; @@.sec.arg.fpu
$end

; ------------------------------------------------------------------------------

; cosecant
; 1 / sine

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get cosecant for some args
;
; cosec(+0)   = PInf
; cosec(-0)   = NInf
; cosec(NaN)  = NaN
; cosec(PInf) = PInf
; cosec(NInf) = NInf

; <- rbx - assign result flag

macro @@.cosec.arg.sse
{
$asprocf @@.cosec.arg

        @@.xmm0.flags.ecx                       ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .return
;       jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x0002                      ; test infinity flag
        jnz    .assign                          ; f(Inf) = Inf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        jmp    .return

   .Zero:                                       ; x = 0
        test    cx, cx                          ; test sign flag
        jns    .PZero
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

macro @@.cosec.arg.fpu
{
$asprocf @@.cosec.arg

        @@.st0.flags.ecx                        ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .return
;       jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x0002                      ; test infinity flag
        jnz    .assign                          ; f(Inf) = Inf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        jmp    .return

   .Zero:                                       ; x = 0
        fstp    st0
        test    cx, cx                          ; test sign flag
        jns    .PZero
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
; @@.cosec.arg.sse
$else
; @@.cosec.arg.fpu
$end

; ------------------------------------------------------------------------------

; tangent

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get tan for some args
;
; tan(+0)   = +0
; tan(-0)   = -0
; tan(NaN)  = NaN
; tan(PInf) = +0
; tan(NInf) = -0

; <- rbx - assign result flag

macro @@.tan.arg.sse
{
$asprocf @@.tan.arg

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

   .NInf:                                       ; x = Negative Infinity
        xorpd   xmm0, xmm0
        @@.chs  xmm0                            ; -0.0
        jmp    .assign

   .PInf:                                       ; x = Positive Infinity
        xorpd   xmm0, xmm0                      ; +0.0
;       jmp    .assign

   .Zero:                                       ; x = 0
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

macro @@.tan.arg.fpu
{
$asprocf @@.tan.arg

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

   .NInf:                                       ; x = Negative Infinity
        fstp    st0
        fldz
        fchs                                    ; -0.0
        jmp    .assign

   .PInf:                                       ; x = Positive Infinity
        fstp    st0
        fldz                                    ; +0.0
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
; @@.tan.arg.sse
$else
; @@.tan.arg.fpu
$end

; ------------------------------------------------------------------------------

; cotangent

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get cotan for some args
;
; cotan(+0)   = PInf
; cotan(-0)   = NInf
; cotan(NaN)  = NaN
; cotan(PInf) = PInf
; cotan(NInf) = NInf

; <- rbx - assign result flag

macro @@.cotan.arg.sse
{
$asprocf @@.cotan.arg

        @@.xmm0.flags.ecx                       ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .return
;       jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x0002                      ; test infinity flag
        jnz    .assign                          ; f(Inf) = Inf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        jmp    .return

   .Zero:                                       ; x = 0
        test    cx, cx                          ; test sign flag
        jns    .PZero
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

macro @@.cotan.arg.fpu
{
$asprocf @@.cotan.arg

        @@.st0.flags.exp.ecx                    ; ecx = flags
        test    cx, 0x0007                      ; test any flag
        jz     .return
;       jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x0002                      ; test infinity flag
        jnz    .assign                          ; f(Inf) = Inf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        jmp    .return

   .Zero:                                       ; x = 0
        fstp    st0
        test    cx, cx                          ; test sign flag
        jns    .PZero
   .Nzero:                                      ; x = -0
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
; @@.cotan.arg.sse
$else
; @@.cotan.arg.fpu
$end

; ------------------------------------------------------------------------------
