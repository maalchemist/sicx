
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (approximate functions utils)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; D = s*(2^e)
;
; -> xmm0
; <- xmm0 = significant
; <- ecx  = exponent

$asproc SIC_AX..xmm0.extract.se.64

        movq    r9, xmm0
        ror     r9, 64-12
        mov     r10, r9
        mov     rcx, r9
        and     rcx, 0x7FF
        jnz    .enz
   .ez:                                         ; ecx = 0
        mov     r8, r9
        shr     r8, 12                          ; r8 = mantissa
        jz     .return                          ; return if xmm0 = 0
   .snz:                                        ; denormalized value
        bsr     r9, r8
        mov     rcx, 51+1
        sub     rcx, r9
        shl     r8, cl
        add     ecx, 1023-1                     ; ecx = exponent
        neg     ecx
        and     r10, 0x800
        or      r10, 0x3FF                      ; set exponent = 1023
        ror     r10, 12
        or      r10, r8
        movq    xmm0, r10                       ; xmm0 = significant
        jmp    .return
   .enz:                                        ; normalized value
        sub     ecx, 1023                       ; ecx = exponent
        mov     r8, 0xFFFFFFFFFFFFF800
        and     r9, r8
        or      r9, 0x3FF                       ; set exponent = 1023
        ror     r9, 12
        movq    xmm0, r9                        ; xmm0 = significant

   .return:
        retn
$endp

$asproc SIC_AX..xmm0.extract.se.32

       .mem     EQU esp - 64

        movsd   [.mem], xmm0
        fld     qword [.mem]

        fxtract                                 ; st0 = significant | st1 = exponent

        fstp    qword [.mem]                    ; st0 = exponent
        movsd   xmm0, [.mem]                    ; xmm0 = significant
        fistp   dword [.mem]
        mov     ecx, dword [.mem]               ; ecx = exponent

   .return:
        retn
$endp

macro SIC_AX.xmm0.extract.se
{
        mov     ecx, SIC_AX..xmm0.extract.se.32
        call    ecx
}

; D = s*(2^e)
;
; -> st0
; <- st0 = significant
; <- st1 = exponent

macro SIC_AX.st0.extract.se
{
        fxtract                                 ; st0 = significant | st1 = exponent
}

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

macro @@exp2.int.sse
{
; -> ebx  - integer exponent
; <- xmm5 - 2^ebx
;
; 1.0 = 0x3FF00000'00000000
; max = 0x7FEFFFFF'FFFFFFFF

$asproc @@exp2.int

   .enter:
   .e.p1024.test:
        cmp     ebx, +1024
        jl     .e.p1024.out
   .e.GE.p1024:                                 ; e >= +1024
        xmovsd  xmm5, SIC_AX.PInf
        jmp    .return
   .e.p1024.out:

   .e.m1023.test:
        cmp     ebx, -1023
        jg     .e.m1023.out
   .e.LE.m1023:                                 ; e <= -1023
        xmovsd  xmm5, SIC_AX.2m1023
        mov     edx, -1023
        sub     edx, ebx
        jz     .return
        movd    xmm4, edx
        psrlq   xmm5, xmm4
        jmp    .return
   .e.m1023.out:

   .main:                                       ; -1023 < e < +1024
        mov     edx, 0x000003FF
        add     edx, ebx
        shl     edx, 32-12
   .assign:
    $ifdef _X64
        movq    xmm5, rdx
    $else
        movd    xmm5, edx
        pslldq  xmm5, 4
    $end

   .return:
        retn
$endp
}

macro @@exp2.int.fpu.64
{
; -> rbx - integer exponent
; <- st0 - 2^rbx
;
; 1.0 = 0x3FF00000'00000000
; max = 0x7FEFFFFF'FFFFFFFF

$asproc @@exp2.int

       .mem     EQU rsp - 64

   .enter:
   .e.p1024.test:
        cmp     rbx, +1024
        jl     .e.p1024.out
   .e.GE.p1024:                                 ; e >= +1024
        fldq    SIC_AX.PInf
        jmp    .return
   .e.p1024.out:

   .e.m1023.test:
        cmp     rbx, -1023
        jg     .e.m1023.out
   .e.LE.m1023:                                 ; e <= -1023
        mov     rcx, -1023
        sub     rcx, rbx
        mov     rdx, 0x0008000000000000
        shr     rdx, cl
        mov     [.mem], rdx
        fld     qword [.mem]
        jmp    .return
   .e.m1023.out:

   .main:                                       ; -1023 < e < +1024
        mov     rdx, 0x000003FF
        add     rdx, rbx
        shl     rdx, 64-12
   .assign:
        mov     [.mem], rdx
        fld     qword [.mem]

   .return:
        retn
$endp
}

macro @@exp2.int.fpu.32
{
; -> ebx - integer exponent
; <- st0 - 2^ebx
;
; 1.0 = 0x3FF00000'00000000
; max = 0x7FEFFFFF'FFFFFFFF

$asproc @@exp2.int

       .mem     EQU esp - 64

   .enter:
   .e.p1024.test:
        cmp     ebx, +1024
        jl     .e.p1024.out
   .e.GE.p1024:                                 ; e >= +1024
        fldq    SIC_AX.PInf
        jmp    .return
   .e.p1024.out:

   .e.m1023.test:
        cmp     ebx, -1023
        jg     .e.m1023.out
   .e.m1043.test:                               ; e <= -1023
        cmp     ebx, -1043
        jg     .e.LE.m1023
   .e.LE.m1043:                                 ; e <= -1043
        mov     ecx, -1043
        sub     ecx, ebx
        mov     edx, 0x80000000
        shr     edx, cl
        mov     dword [.mem + 4], 0
        mov     dword [.mem], edx
        fld     qword [.mem]
        jmp    .return
   .e.LE.m1023:                                 ; -1043 < e <= -1023
        mov     ecx, -1023
        sub     ecx, ebx
        mov     edx, 0x00080000
        shr     edx, cl
        mov     dword [.mem + 4], edx
        mov     dword [.mem], 0
        fld     qword [.mem]
        jmp    .return
   .e.m1023.out:

   .main:                                       ; -1023 < e < +1024
        mov     edx, 0x000003FF
        add     edx, ebx
        shl     edx, 32-12
   .assign:
        mov     dword [.mem + 4], edx
        mov     dword [.mem], 0
        fld     qword [.mem]

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@exp2.int.sse
$else
  @@exp2.int.fpu.32
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; 2^x

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get 2^x for some args
;
; 2^(0)    = 1
; 2^(NaN)  = NaN
; 2^(PInf) = PInf
; 2^(NInf) = 0

; <- ebx - assign result flag

macro @@exp2.arg.sse
{
$asprocf @@exp2.arg

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
        xmovsd  xmm4, ??.SD_fexp2_max_arg
        comisd  xmm0, xmm4                      ; compare x to max_arg
        ja     .max                             ; jump if x > max_arg

        xmovsd  xmm4, ??.SD_fexp2_min_arg
        comisd  xmm0, xmm4                      ; compare x to min_arg
        jae    .return                          ; jump if x >= min_arg

   .min:                                        ; x <= min_arg
   .NInf:                                       ; x = Negative Infinity
        xorpd   xmm0, xmm0
        jmp    .assign

   .max:                                        ; x >= max_arg
        xmovsd  xmm0, SIC_AX.PInf
        jmp    .assign

   .Zero:                                       ; x = 0
   .assign.1.0:
        xmovsd  xmm0, SIC_AX.1.0
;       jmp    .assign

   .assign:
        xor     ebx, ebx

   .return:
        retn
$endp
}

macro @@exp2.arg.fpu
{
$asprocf @@exp2.arg

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
        fldq    ??.SD_fexp2_max_arg
        fcomp                                   ; compare max_arg to x
        fnjl   .max                             ; jump if x > max_arg (max_arg < x)

        fldq    ??.SD_fexp2_min_arg
        fcomp                                   ; compare min_arg to x
        fnjle  .return                          ; jump if x >= min_arg (min_arg <= x)

   .min:                                        ; x <= min_arg
   .NInf:                                       ; x = Negative Infinity
        fstp    st0
        fldz
        jmp    .assign

   .max:                                        ; x >= max_arg
        fstp    st0
        fldq    SIC_AX.PInf
        jmp    .assign

   .Zero:                                       ; x = 0
   .assign.1.0:
        fstp    st0
        fld1
;       jmp    .assign

   .assign:
        xor     ebx, ebx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@exp2.arg.sse
$else
  @@exp2.arg.fpu
$end

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@exp2.reduce.sse
{
; -> xmm0 - exponent
; <- xmm0 - reduced exponent (|x0| < 0.5)
; <- ebx  - integer exponent

$asproc @@exp2.reduce

   .enter:
        cvttsd2si ebx, xmm0                     ; ebx = trunc(x)
        cvtsi2sd  xmm5, ebx                     ; xmm5 = trunc(x)
        subsd     xmm0, xmm5                    ; xmm0 = frac(x)
        ;
        xmovsd  xmm5, SIC_AX.0.5
        comisd  xmm0, xmm5
        ja     .L2
;       xmovsd  xmm5, SIC_AX.m0.5
        @@.chs  xmm5
        comisd  xmm0, xmm5
        jae    .return
   .L0:
        xmovsd  xmm5, SIC_AX.1.0
        addsd   xmm0, xmm5
        dec     ebx
        jmp    .return
   .L2:
        xmovsd  xmm5, SIC_AX.1.0
        subsd   xmm0, xmm5
        inc     ebx

   .return:
        retn
$endp
}

macro @@exp2.reduce.fpu
{
; -> st0 - exponent
; <- st0 - reduced exponent (|x0| < 0.5)
; <- ebx - integer exponent

$asproc @@exp2.reduce

   .enter:
        @@.trunc.frac.st0 ebx                   ; st0 = frac(x) | ebx = trunc(x)
        ;
        fldq    SIC_AX.0.5
        fcomp
        fnjl   .L2                              ; jump if x > 0.5 (0.5 < x)
        fldq    SIC_AX.m0.5
        fcomp
        fnjle  .return                          ; jump if x >= -0.5 (-0.5 <= x)
   .L0:
        fld1
        faddp
        dec     ebx
        jmp    .return
   .L2:
        fld1
        fsubp
        inc     ebx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@exp2.reduce.sse
$else
  @@exp2.reduce.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; 10^x

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@exp10.reduce.sse
{
; -> xmm0 - exponent
; <- xmm0 - reduced exponent (|x0| < 0.5)
; <- ebx  - integer exponent

$asproc @@exp10.reduce

   .enter:
        cvttsd2si ebx, xmm0                     ; ebx = trunc(x)
        cvtsi2sd  xmm5, ebx                     ; xmm5 = trunc(x)
        subsd     xmm0, xmm5                    ; xmm0 = frac(x)

   .return:
        retn
$endp
}

macro @@exp10.reduce.fpu
{
; -> st0 - exponent
; <- st0 - reduced exponent (|x0| < 0.5)
; <- ebx - integer exponent

$asproc @@exp10.reduce

   .enter:
        @@.trunc.frac.st0 ebx                   ; st0 = frac(x) | ebx = trunc(x)

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@exp10.reduce.sse
$else
  @@exp10.reduce.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; loge(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get loge(x) for some args
;
; loge(<0)   = NaN
; loge(+0)   = NInf
; loge(NaN)  = NaN
; loge(PInf) = PInf

; <- ebx - assign result flag

macro @@loge.arg.sse
{
$asprocf @@loge.arg

        @@.xmm0.flags.ecx                       ; ecx = flags
        test    cx, 0x8007                      ; test any flag
        jz     .return
        test    cx, 0x8000                      ; test sign flag
        jnz    .assign.NaN
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x0006                      ; test infinity and nan flags
        jz     .return

   .Inf:                                        ; x = Positive Infinity
   .NaN:                                        ; x = Not a Number
        jmp    .assign                          ; f(PInf) = PInf | f(NaN) = NaN

   .assign.NaN:
        xmovsd  xmm0, SIC_AX.NaN
        jmp    .assign

   .Zero:                                       ; x = +0
   .assign.NInf:
        xmovsd  xmm0, SIC_AX.NInf
;       jmp    .assign

   .assign:
        xor     ebx, ebx

   .return:
        retn
$endp
}

macro @@loge.arg.fpu
{
$asprocf @@loge.arg

        @@.st0.flags.ecx                        ; ecx = flags
        test    cx, 0x8007                      ; test any flag
        jz     .return
        test    cx, 0x8000                      ; test sign flag
        jnz    .assign.NaN
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x0006                      ; test infinity and nan flags
        jz     .return

   .Inf:                                        ; x = Positive Infinity
   .NaN:                                        ; x = Not a Number
        jmp    .assign                          ; f(PInf) = PInf | f(NaN) = NaN

   .assign.NaN:
        fstp    st0
        fldq    SIC_AX.NaN
        jmp    .assign

   .Zero:                                       ; x = +0
   .assign.NInf:
        fstp    st0
        fldq    SIC_AX.NInf
;       jmp    .assign

   .assign:
        xor     ebx, ebx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@loge.arg.sse
$else
  @@loge.arg.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; x^y

DEFINE SIC_AX.POW_INT TRUE

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get x^y for some args
; https://en.cppreference.com/w/cpp/numeric/math/pow
;
; x^(+0.0)          = 1.0
; x^(-0.0)          = 1.0
; NaN^(y)           = NaN
; 1.0^(NaN)         = 1.0
; x^(NaN)           = NaN
; +0.0^(PInf)       = +0.0
; -0.0^(PInf)       = +0.0
; +0.0^(NInf)       = PInf
; -0.0^(NInf)       = PInf
; +0.0^(-odd)       = PInf
; +0.0^(-even)      = PInf
; +0.0^(+odd)       = +0.0
; +0.0^(+even)      = +0.0
; -0.0^(-odd)       = NInf
; -0.0^(-even)      = PInf
; -0.0^(+odd)       = -0.0
; -0.0^(+even)      = +0.0
; +0.0^(-non-int)   = PInf
; -0.0^(-non-int)   = PInf
; +0.0^(+non-int)   = +0.0
; -0.0^(+non-int)   = +0.0
; PInf^(y>0)        = PInf
; PInf^(y<0)        = +0.0
; NInf^(-odd)       = -0.0
; NInf^(-even)      = +0.0
; NInf^(+odd)       = NInf
; NInf^(+even)      = PInf
; NInf^(-non-int)   = +0.0
; NInf^(+non-int)   = PInf
;
; (|x|=1.0)^(PInf)  = 1.0
; (|x|<1.0)^(PInf)  = +0.0
; (|x|>1.0)^(PInf)  = PInf
;
; (|x|=1.0)^(NInf)  = 1.0
; (|x|<1.0)^(NInf)  = PInf
; (|x|>1.0)^(NInf)  = +0.0
;
; x^(1.0)           = x
; 1.0^(y)           = 1.0
; (x<0.0)^(non-int) = NaN
; (x<0.0)^(odd)     = NaN?

; <- ebx - assign result flag

; -> x = xmm0
; -> y = xmm1
macro @@power.arg.sse
{
$asprocf @@power.arg

        @@.xmm0.flags.ecx                       ; ecx = x flags
        @@.xmm1.flags.exp.edx                   ; edx = y flags and exponent
   .y.int.flags:
        xor     edi, edi
        test    dx, 0x0006                      ; test y infinity or nan flags
        jnz    .y.int.flags.out
        ;
        push    edx
        @@.xmm1.int.flags.edi                   ; edi = y integer flags
        pop     edx
   .y.int.flags.out:

        mov     ebx, SIC_AX.1.0                 ; ebx = +1.0

        test    dx, 0x0001                      ; test y zero flag
        jnz    .assign.1.0                      ; x^(0.0) = 1.0
        test    cx, 0x0004                      ; test x nan flag
        jnz    .assign.NaN                      ; NaN^(y) = NaN
        test    dx, 0x0004                      ; test y nan flag
        jnz    .y.NaN
        test    cx, 0x0001                      ; test x zero flag
        jnz    .x.Zero
        cmp     cx, 0x0002                      ; is x positive infinity?
        je     .x.PInf
        cmp     cx, 0x8002                      ; is x negative infinity?
        je     .x.NInf
        cmp     dx, 0x0002                      ; is y positive infinity?
        je     .y.PInf
        cmp     dx, 0x8002                      ; is y negative infinity?
        je     .y.NInf

   .main:
        comisd  xmm1, qword [ebx]               ; compare y to 1.0
        jnz    .y.NE.1.0                        ; jump if y <> 1.0
        jp     .y.NE.1.0
   .y.EQ.1.0:                                   ; y = 1.0
        jmp    .assign                          ; x^(1.0) = x
   .y.NE.1.0:                                   ; y <> 1.0
        comisd  xmm0, qword [ebx]               ; compare x to 1.0
        jnz    .x.NE.1.0                        ; jump if x <> 1.0
        jp     .x.NE.1.0
   .x.EQ.1.0:                                   ; x = 1.0
        jmp    .assign.1.0                      ; 1.0^(y) = 1.0
   .x.NE.1.0:                                   ; x <> 1.0
;       xorpd   xmm5, xmm5
;       comisd  xmm0, xmm5                      ; compare x to 0.0
;       jb     .x.Neg                           ; jump if x < 0.0
        test    cx, 0x8000                      ; test x sign flag
        jnz    .x.Neg                           ; jump if x is negative
   .x.Pos:
        shr     edx, 32-12
        cmp     edx, 1023-63
        jae    .return                          ; jump if |x| >= 2^(-63)
   .x.Pos.y.eps:                                ; |y| < 2^(-63)
        jmp    .assign.1.0
   .x.Neg:
        test    edi, 0x0002                     ; test y integer flag
        jz     .assign.NaN                      ; (x<0.0)^(non-int) = NaN
   .x.Neg.y.Int:
    $ifdef      SIC_AX.POW_INT
        jmp    .return
    $else
        test    edi, 0x0001                     ; test y odd flag
        jnz    .assign.NaN                      ; (x<0.0)^(odd) = NaN
    $end
   .x.Neg.y.Int.Even:
        @@.abs  xmm0
        jmp    .return                          ; (x<0.0)^(even) = (|x|)^(even)

   .x.Zero:
        cmp     dx, 0x0002                      ; is y positive infinity?
        je     .assign.PZero                    ; 0.0^(PInf) = +0.0
        cmp     dx, 0x8002                      ; is y negative infinity?
        je     .assign.PInf                     ; 0.0^(NInf) = PInf
        ;
        test    edi, 0x0002                     ; test y integer flag
        jz     .x.Zero.y.NotInt
        ;
   .x.Zero.y.Int:
        test    cx, 0x8000                      ; test x sign flag
        jz     .x.PZero.y.Int
        ;
   .x.NZero.y.Int:
        test    dx, 0x8000                      ; test y sign flag
        jz     .x.NZero.y.PInt
        ;
   .x.NZero.y.NInt:
        test    edi, 0x0001                     ; test y odd flag
        jz     .x.NZero.y.NInt.Even
   .x.NZero.y.NInt.Odd:                         ; y = negative odd integer
        jmp    .assign.NInf                     ; -0.0^(-odd) = NInf
   .x.NZero.y.NInt.Even:                        ; y = negative even integer
        jmp    .assign.PInf                     ; -0.0^(-even) = PInf
        ;
   .x.NZero.y.PInt:
        test    edi, 0x0001                     ; test y odd flag
        jz     .x.NZero.y.PInt.Even
   .x.NZero.y.PInt.Odd:                         ; y = positive odd integer
        jmp    .assign.NZero                    ; -0.0^(+odd) = -0.0
   .x.NZero.y.PInt.Even:                        ; y = positive even integer
        jmp    .assign.PZero                    ; -0.0^(+even) = +0.0
        ;
   .x.PZero.y.Int:
        test    dx, 0x8000                      ; test y sign flag
        jz     .x.PZero.y.PInt
        ;
   .x.PZero.y.NInt:
        jmp    .assign.PInf
;       test    edi, 0x0001                     ; test y odd flag
;       jz     .x.PZero.y.NInt.Even
;  .x.PZero.y.NInt.Odd:                         ; y = negative odd integer
;       jmp    .assign.PInf                     ; +0.0^(-odd) = PInf
;  .x.PZero.y.NInt.Even:                        ; y = negative even integer
;       jmp    .assign.PInf                     ; +0.0^(-even) = PInf
        ;
   .x.PZero.y.PInt:
        jmp    .assign.PZero
;       test    edi, 0x0001                     ; test y odd flag
;       jz     .x.PZero.y.PInt.Even
;  .x.PZero.y.PInt.Odd:                         ; y = positive odd integer
;       jmp    .assign.PZero                    ; +0.0^(+odd) = +0.0
;  .x.PZero.y.PInt.Even:                        ; y = positive even integer
;       jmp    .assign.PZero                    ; +0.0^(+even) = +0.0
        ;
   .x.Zero.y.NotInt:
        test    dx, 0x8000                      ; test y sign flag
        jz     .x.Zero.y.NotInt.Pos
   .x.Zero.y.NotInt.Neg:                        ; y = negative non-integer
        jmp    .assign.PInf                     ; 0.0^(-non-int) = PInf
   .x.Zero.y.NotInt.Pos:                        ; y = positive non-integer
        jmp    .assign.PZero                    ; 0.0^(+non-int) = +0.0

   .x.PInf:
        test    dx, 0x8000                      ; test y sign flag
        jz     .assign                          ; PInf^(y>0) = PInf
;       jz     .assign.PInf                     ; PInf^(y>0) = PInf
   .x.PInf.y.Neg:
        jmp    .assign.PZero                    ; PInf^(y<0) = +0.0

   .x.NInf:
        test    edi, 0x0002                     ; test y integer flag
        jz     .x.NInf.y.NotInt
        ;
   .x.NInf.y.Int:
        test    dx, 0x8000                      ; test y sign flag
        jz     .x.NInf.y.PInt
        ;
   .x.NInf.y.NInt:
        test    edi, 0x0001                     ; test y odd flag
        jz     .x.NInf.y.NInt.Even
   .x.NInf.y.NInt.Odd:                          ; y = negative odd integer
        jmp    .assign.NZero                    ; NInf^(-odd) = -0.0
   .x.NInf.y.NInt.Even:                         ; y = negative even integer
        jmp    .assign.PZero                    ; NInf^(-even) = +0.0
        ;
   .x.NInf.y.PInt:
        test    edi, 0x0001                     ; test y odd flag
        jz     .x.NInf.y.PInt.Even
   .x.NInf.y.PInt.Odd:                          ; y = positive odd integer
        jmp    .assign.NInf                     ; NInf^(+odd) = NInf
   .x.NInf.y.PInt.Even:                         ; y = positive even integer
        jmp    .assign.PInf                     ; NInf^(+even) = PInf
        ;
   .x.NInf.y.NotInt:
        test    dx, 0x8000                      ; test y sign flag
        jz     .x.NInf.y.NotInt.Pos
   .x.NInf.y.NotInt.Neg:                        ; y = negative non-integer
        jmp    .assign.PZero                    ; NInf^(-non-int) = +0.0
   .x.NInf.y.NotInt.Pos:                        ; y = positive non-integer
        jmp    .assign.PInf                     ; NInf^(+non-int) = PInf

   .y.NaN:
        comisd  xmm0, qword [ebx]               ; compare x to 1.0
        jnz    .assign.NaN                      ; assign NaN if x <> 1.0
        jp     .assign.NaN
   .y.NaN.x.1.0:
        jmp    .assign.1.0                      ; 1.0^(NaN) = 1

   .y.PInf:
        xmovx   xmm5, xmm0
        @@.abs  xmm5
        comisd  xmm5, qword [ebx]               ; compare |x| to 1.0
        jb     .y.PInf.x.LT.1.0
        ja     .y.PInf.x.GT.1.0
   .y.PInf.x.EQ.1.0:                            ; |x| = 1.0
        jmp    .assign.1.0                      ; (|x|=1.0)^(PInf) = 1.0
   .y.PInf.x.LT.1.0:                            ; |x| < 1.0
        jmp    .assign.PZero                    ; (|x|<1.0)^(PInf) = +0.0
   .y.PInf.x.GT.1.0:                            ; |x| > 1.0
        jmp    .assign.PInf                     ; (|x|>1.0)^(PInf) = PInf

   .y.NInf:
        xmovx   xmm5, xmm0
        @@.abs  xmm5
        comisd  xmm5, qword [ebx]               ; compare |x| to 1.0
        jb     .y.NInf.x.LT.1.0
        ja     .y.NInf.x.GT.1.0
   .y.NInf.x.EQ.1.0:                            ; |x| = 1.0
        jmp    .assign.1.0                      ; (|x|=1.0)^(NInf) = 1.0
   .y.NInf.x.LT.1.0:                            ; |x| < 1.0
        jmp    .assign.PInf                     ; (|x|<1.0)^(NInf) = PInf
   .y.NInf.x.GT.1.0:                            ; |x| > 1.0
        jmp    .assign.PZero                    ; (|x|>1.0)^(NInf) = +0.0

   .assign.PInf:
        xmovsd  xmm0, SIC_AX.PInf
        jmp    .assign

   .assign.NInf:
        xmovsd  xmm0, SIC_AX.NInf
        jmp    .assign

   .assign.NaN:
        xmovsd  xmm0, SIC_AX.NaN
        jmp    .assign

   .assign.1.0:
        movsd   xmm0, qword [ebx]
        jmp    .assign

   .assign.NZero:
        xorpd   xmm0, xmm0
        @@.chs  xmm0
        jmp    .assign

   .assign.PZero:
        xorpd   xmm0, xmm0
;       jmp    .assign

   .assign:
        xor     ebx, ebx

   .return:
        retn
$endp
}

; -> x = st0
; -> y = st1
macro @@power.arg.fpu
{
$asprocf @@power.arg

        @@.st0.flags.ecx                        ; ecx = x flags
        fxch                                    ; st0 = y | st0 = x
        @@.st0.flags.exp.edx                    ; edx = y flags and exponent
   .y.int.flags:
        xor     edi, edi
        test    dx, 0x0006                      ; test y infinity or nan flags
        jnz    .y.int.flags.out
        ;
        push    edx
        @@.st0.int.flags.edi                    ; edi = y integer flags
        pop     edx
   .y.int.flags.out:
        fxch                                    ; st0 = x | st0 = y

        mov     ebx, SIC_AX.1.0                 ; ebx = +1.0

        test    dx, 0x0001                      ; test y zero flag
        jnz    .assign.1.0                      ; x^(0.0) = 1.0
        test    cx, 0x0004                      ; test x nan flag
        jnz    .assign.NaN                      ; NaN^(y) = NaN
        test    dx, 0x0004                      ; test y nan flag
        jnz    .y.NaN
        test    cx, 0x0001                      ; test x zero flag
        jnz    .x.Zero
        cmp     cx, 0x0002                      ; is x positive infinity?
        je     .x.PInf
        cmp     cx, 0x8002                      ; is x negative infinity?
        je     .x.NInf
        cmp     dx, 0x0002                      ; is y positive infinity?
        je     .y.PInf
        cmp     dx, 0x8002                      ; is y negative infinity?
        je     .y.NInf

   .main:                                       ; st0 = x | st1 = y
        fld1                                    ; st0 = 1 | st1 = x | st2 = y
        fcomp   st2                             ; compare 1.0 to y
        fnjne  .y.NE.1.0                        ; jump if y <> 1.0
   .y.EQ.1.0:                                   ; y = 1.0
        fstp    st1                             ; st0 = x
        jmp    .assign                          ; x^(1.0) = x
   .y.NE.1.0:                                   ; y <> 1.0
        fld1                                    ; st0 = 1 | st1 = x | st2 = y
        fcomp                                   ; compare 1.0 to x
        fnjne  .x.NE.1.0                        ; jump if x <> 1.0
   .x.EQ.1.0:                                   ; x = 1.0
        jmp    .assign.1.0
   .x.NE.1.0:                                   ; x <> 1.0
;       ftst                                    ; compare x to 0.0
;       fnjl   .x.Neg                           ; jump if x < 0.0
        test    cx, 0x8000                      ; test x sign flag
        jnz    .x.Neg                           ; jump if x is negative
   .x.Pos:
        shr     edx, 32-12
        cmp     edx, 1023-63
        jae    .return                          ; jump if |x| >= 2^(-63)
   .x.Pos.y.eps:                                ; |y| < 2^(-63)
        jmp    .assign.1.0
   .x.Neg:
        test    edi, 0x0002                     ; test y integer flag
        jz     .assign.NaN                      ; (x<0.0)^(non-int) = NaN
   .x.Neg.y.Int:
    $ifdef      SIC_AX.POW_INT
        jmp    .return
    $else
        test    edi, 0x0001                     ; test y odd flag
        jnz    .assign.NaN                      ; (x<0.0)^(odd) = NaN
    $end
   .x.Neg.y.Int.Even:
        fabs
        jmp    .return                          ; (x<0.0)^(even) = (|x|)^(even)

   .x.Zero:
        cmp     dx, 0x0002                      ; is y positive infinity?
        je     .assign.PZero                    ; 0.0^(PInf) = +0.0
        cmp     dx, 0x8002                      ; is y negative infinity?
        je     .assign.PInf                     ; 0.0^(NInf) = PInf
        ;
        test    edi, 0x0002                     ; test y integer flag
        jz     .x.Zero.y.NotInt
        ;
   .x.Zero.y.Int:
        test    cx, 0x8000                      ; test x sign flag
        jz     .x.PZero.y.Int
        ;
   .x.NZero.y.Int:
        test    dx, 0x8000                      ; test y sign flag
        jz     .x.NZero.y.PInt
        ;
   .x.NZero.y.NInt:
        test    edi, 0x0001                     ; test y odd flag
        jz     .x.NZero.y.NInt.Even
   .x.NZero.y.NInt.Odd:                         ; y = negative odd integer
        jmp    .assign.NInf                     ; -0.0^(-odd) = NInf
   .x.NZero.y.NInt.Even:                        ; y = negative even integer
        jmp    .assign.PInf                     ; -0.0^(-even) = PInf
        ;
   .x.NZero.y.PInt:
        test    edi, 0x0001                     ; test y odd flag
        jz     .x.NZero.y.PInt.Even
   .x.NZero.y.PInt.Odd:                         ; y = positive odd integer
        jmp    .assign.NZero                    ; -0.0^(+odd) = -0.0
   .x.NZero.y.PInt.Even:                        ; y = positive even integer
        jmp    .assign.PZero                    ; -0.0^(+even) = +0.0
        ;
   .x.PZero.y.Int:
        test    dx, 0x8000                      ; test y sign flag
        jz     .x.PZero.y.PInt
        ;
   .x.PZero.y.NInt:
        jmp    .assign.PInf
;       test    edi, 0x0001                     ; test y odd flag
;       jz     .x.PZero.y.NInt.Even
;  .x.PZero.y.NInt.Odd:                         ; y = negative odd integer
;       jmp    .assign.PInf                     ; +0.0^(-odd) = PInf
;  .x.PZero.y.NInt.Even:                        ; y = negative even integer
;       jmp    .assign.PInf                     ; +0.0^(-even) = PInf
        ;
   .x.PZero.y.PInt:
        jmp    .assign.PZero
;       test    edi, 0x0001                     ; test y odd flag
;       jz     .x.PZero.y.PInt.Even
;  .x.PZero.y.PInt.Odd:                         ; y = positive odd integer
;       jmp    .assign.PZero                    ; +0.0^(+odd) = +0.0
;  .x.PZero.y.PInt.Even:                        ; y = positive even integer
;       jmp    .assign.PZero                    ; +0.0^(+even) = +0.0
        ;
   .x.Zero.y.NotInt:
        test    dx, 0x8000                      ; test y sign flag
        jz     .x.Zero.y.NotInt.Pos
   .x.Zero.y.NotInt.Neg:                        ; y = negative non-integer
        jmp    .assign.PInf                     ; 0.0^(-non-int) = PInf
   .x.Zero.y.NotInt.Pos:                        ; y = positive non-integer
        jmp    .assign.PZero                    ; 0.0^(+non-int) = +0.0

   .x.PInf:
        test    dx, 0x8000                      ; test y sign flag
        jz     .assign.PInf                     ; PInf^(y>0) = PInf
   .x.PInf.y.Neg:
        jmp    .assign.PZero                    ; PInf^(y<0) = +0.0

   .x.NInf:
        test    edi, 0x0002                     ; test y integer flag
        jz     .x.NInf.y.NotInt
        ;
   .x.NInf.y.Int:
        test    dx, 0x8000                      ; test y sign flag
        jz     .x.NInf.y.PInt
        ;
   .x.NInf.y.NInt:
        test    edi, 0x0001                     ; test y odd flag
        jz     .x.NInf.y.NInt.Even
   .x.NInf.y.NInt.Odd:                          ; y = negative odd integer
        jmp    .assign.NZero                    ; NInf^(-odd) = -0.0
   .x.NInf.y.NInt.Even:                         ; y = negative even integer
        jmp    .assign.PZero                    ; NInf^(-even) = +0.0
        ;
   .x.NInf.y.PInt:
        test    edi, 0x0001                     ; test y odd flag
        jz     .x.NInf.y.PInt.Even
   .x.NInf.y.PInt.Odd:                          ; y = positive odd integer
        jmp    .assign.NInf                     ; NInf^(+odd) = NInf
   .x.NInf.y.PInt.Even:                         ; y = positive even integer
        jmp    .assign.PInf                     ; NInf^(+even) = PInf
        ;
   .x.NInf.y.NotInt:
        test    dx, 0x8000                      ; test y sign flag
        jz     .x.NInf.y.NotInt.Pos
   .x.NInf.y.NotInt.Neg:                        ; y = negative non-integer
        jmp    .assign.PZero                    ; NInf^(-non-int) = +0.0
   .x.NInf.y.NotInt.Pos:                        ; y = positive non-integer
        jmp    .assign.PInf                     ; NInf^(+non-int) = PInf

   .y.NaN:
        fld1
        fcomp                                   ; compare 1.0 to x
        fnjne  .assign.NaN                      ; assign NaN if x <> 1.0
   .y.NaN.x.1.0:
        jmp    .assign.1.0                      ; 1.0^(NaN) = 1

   .y.PInf:
        fld     st0
        fabs
        fcomp   qword [ebx]                     ; compare |x| to 1.0
        fnjl   .y.PInf.x.LT.1.0
        fnjg   .y.PInf.x.GT.1.0
   .y.PInf.x.EQ.1.0:                            ; |x| = 1.0
        jmp    .assign.1.0                      ; (|x|=1.0)^(PInf) = 1.0
   .y.PInf.x.LT.1.0:                            ; |x| < 1.0
        jmp    .assign.PZero                    ; (|x|<1.0)^(PInf) = +0.0
   .y.PInf.x.GT.1.0:                            ; |x| > 1.0
        jmp    .assign.PInf                     ; (|x|>1.0)^(PInf) = PInf

   .y.NInf:
        fld     st0
        fabs
        fcomp   qword [ebx]                     ; compare |x| to 1.0
        fnjl   .y.NInf.x.LT.1.0
        fnjg   .y.NInf.x.GT.1.0
   .y.NInf.x.EQ.1.0:                            ; |x| = 1.0
        jmp    .assign.1.0                      ; (|x|=1.0)^(NInf) = 1.0
   .y.NInf.x.LT.1.0:                            ; |x| < 1.0
        jmp    .assign.PInf                     ; (|x|<1.0)^(NInf) = PInf
   .y.NInf.x.GT.1.0:                            ; |x| > 1.0
        jmp    .assign.PZero                    ; (|x|>1.0)^(NInf) = +0.0

   .assign.PInf:
        fldq    SIC_AX.PInf
        jmp    .assign.STP

   .assign.NInf:
        fldq    SIC_AX.NInf
        jmp    .assign.STP

   .assign.NaN:
        fldq    SIC_AX.NaN
        jmp    .assign.STP

   .assign.1.0:
        fld1
        jmp    .assign.STP

   .assign.NZero:
        fldz
        fchs
        jmp    .assign.STP

   .assign.PZero:
        fldz
;       jmp    .assign.STP

   .assign.STP:
        fstp    st1
        fstp    st1
   .assign:
        xor     ebx, ebx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@power.arg.sse
$else
  @@power.arg.fpu
$end

; ------------------------------------------------------------------------------
