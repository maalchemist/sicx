
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (approximate trigonometric functions utils)

; Copyright � 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; angle disposition
; 0 <= x < 2*pi
;
; 0 : 0*pi/4 <= x < 1*pi/4    x = x0
; 1 : 1*pi/4 <= x < 2*pi/4    x = pi/2 - x0
; 2 : 2*pi/4 <= x < 3*pi/4    x = pi/2 + x0
; 3 : 3*pi/4 <= x < 4*pi/4    x = pi - x0
; 4 : 4*pi/4 <= x < 5*pi/4    x = pi + x0
; 5 : 5*pi/4 <= x < 6*pi/4    x = 3*pi/2 - x0
; 6 : 6*pi/4 <= x < 7*pi/4    x = 3*pi/2 + x0
; 7 : 7*pi/4 <= x < 8*pi/4    x = 2*pi - x0
;
; 0 <= x0 < pi/4

; ------------------------------------------------------------------------------

$ifdef _X64
TG.arg.max.exp = 51 ; 62
$else
TG.arg.max.exp = 51 ; 62
$endif

; frac ((2^50)/(pi/4)) = 0.5
; frac ((2^51)/(pi/4)) = 0.0

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; x = (pi/4)*(x div pi/4) + (x mod pi/4)
;   = (pi/4)*(n) + (x mod pi/4)

; -> xmm0 = x
; <- xmm0 = x mod pi/4
; x64
; <- rcx  = n
; x32
; <- ecx  = n.LO
; <- edx  = n.HI

macro @@.xmm0.div.mod.pi4
{
        local   @mem
        @mem    EQU rsp - 64

        xmovsd  xmm5, SIC_AX.1D.pi4             ; xmm5 = 1/(pi/4) = 1/y
        xmovx   xmm4, xmm0                      ; xmm4 = x
        mulsd   xmm4, xmm5                      ; xmm4 = x/y
        xintsd  xmm4, xmm4                      ; xmm4 = int(x/y) = n
    $ifdef _X64
        cvttsd2si rcx, xmm4                     ; |xmm4| < 2^64
    $else
;       cvttsd2si ecx, xmm4                     ; |xmm4| < 2^32
        movsd   qword [@mem], xmm4
        fld     qword [@mem]
        fistp   qword [@mem]                    ; |st0| < 2^64
        mov     ecx, dword [@mem]               ; ecx = n.LO
        mov     edx, dword [@mem + 4]           ; edx = n.HI
    $end
        xmovsd  xmm5, SIC_AX.pi4                ; xmm5 = pi/4 = y
        mulsd   xmm4, xmm5                      ; xmm4 = y*n
        subsd   xmm0, xmm4                      ; xmm0 = x - y*n = x mod pi/4
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; |x'| < 2

; -> xmm0 = x'
; <- xmm0 = x mod pi/4
; <- rcx  = n

macro @@.xmm0.pi.div.mod.pi4
{
        xmovsd  xmm5, SIC_AX.pi
        mulsd   xmm0, xmm5                      ; xmm0 = PI*x' = x

        xmovsd  xmm5, SIC_AX.1D.pi4             ; xmm5 = 1/(pi/4) = 1/y
        xmovx   xmm4, xmm0                      ; xmm4 = x
        mulsd   xmm4, xmm5                      ; xmm4 = x/y
        xintsd  xmm4, xmm4                      ; xmm4 = int(x/y) = n
        cvttsd2si rcx, xmm4
        xmovsd  xmm5, SIC_AX.pi4                ; xmm5 = pi/4 = y
        mulsd   xmm4, xmm5                      ; xmm4 = y*n
        subsd   xmm0, xmm4                      ; xmm0 = x - y*n = x mod pi/4
}

; ------------------------------------------------------------------------------

; x = (pi/4)*(x div pi/4) + (x mod pi/4)
;   = (pi/4)*(n) + (x mod pi/4)

; -> st0 = x
; <- st0 = x mod pi/4
; x64
; <- rcx  = n
; x32
; <- ecx  = n.LO
; <- edx  = n.HI

macro @@.st0.div.mod.pi4
{
        local   @mem
        @mem    EQU rsp - 64

        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions

        fld     st0
        fmulq   SIC_AX.1D.pi4                   ; st0 = x/y          | st1 = x
        frndint                                 ; st0 = int(x/y) = n | st1 = x
        fistp   qword [@mem]                    ; |st0| < 2^64
    $ifdef _X64
        mov     rcx, qword [@mem]               ; rcx = n
    $else
        mov     ecx, dword [@mem]               ; ecx = n.LO
        mov     edx, dword [@mem + 4]           ; edx = n.HI
    $end
        fldq    SIC_AX.pi4                      ; st0 = pi/4       | st1 = x
        fxch                                    ; st0 = x          | st1 = pi/4
        fprem                                   ; st0 = x mod pi/4 | st1 = pi/4
        fstp    st1                             ; st0 = x mod pi/4

        @@.fpu.cw.restore                       ; restore control word
}

macro @@..st0.div.mod.pi4
{
        local   @mem
        @mem    EQU rsp - 64

        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions

        fld     st0
        fmulq   SIC_AX.1D.pi4                   ; st0 = x/y          | st1 = x
        frndint                                 ; st0 = int(x/y) = n | st1 = x
        fld     st0
        fistp   qword [@mem]                    ; |st0| < 2^64
    $ifdef _X64
        mov     rcx, qword [@mem]               ; rcx = n
    $else
        mov     ecx, dword [@mem]               ; ecx = n.LO
        mov     edx, dword [@mem + 4]           ; edx = n.HI
    $end
        fmulq   SIC_AX.pi4                      ; st0 = y*n          | st1 = x
        fsubp                                   ; st0 = x - y*n = x mod pi/4

        @@.fpu.cw.restore                       ; restore control word
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; |x'| < 2

; -> st0 = x'
; <- st0 = x mod pi/4
; x64
; <- rcx  = n
; x32
; <- ecx  = n.LO
; <- edx  = n.HI

macro @@.st0.pi.div.mod.pi4
{
        local   @mem
        @mem    EQU rsp - 64

        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions

        fldpi
        fmulp                                   ; st0 = PI*x' = x

        fld     st0
        fmulq   SIC_AX.1D.pi4                   ; st0 = x/y          | st1 = x
        frndint                                 ; st0 = int(x/y) = n | st1 = x
        fistp   qword [@mem]                    ; |st0| < 2^64
    $ifdef _X64
        mov     rcx, qword [@mem]               ; rcx = n
    $else
        mov     ecx, dword [@mem]               ; ecx = n.LO
        mov     edx, dword [@mem + 4]           ; edx = n.HI
    $end
        fldq    SIC_AX.pi4                      ; st0 = pi/4       | st1 = x
        fxch                                    ; st0 = x          | st1 = pi/4
        fprem                                   ; st0 = x mod pi/4 | st1 = pi/4
        fstp    st1                             ; st0 = x mod pi/4

        @@.fpu.cw.restore                       ; restore control word
}

macro @@..st0.pi.div.mod.pi4
{
        local   @mem
        @mem    EQU rsp - 64

        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions

        fldpi
        fmulp                                   ; st0 = PI*x' = x

        fld     st0
        fmulq   SIC_AX.1D.pi4                   ; st0 = x/y          | st1 = x
        frndint                                 ; st0 = int(x/y) = n | st1 = x
        fld     st0
        fistp   qword [@mem]                    ; |st0| < 2^64
    $ifdef _X64
        mov     rcx, qword [@mem]               ; rcx = n
    $else
        mov     ecx, dword [@mem]               ; ecx = n.LO
        mov     edx, dword [@mem + 4]           ; edx = n.HI
    $end
        fmulq   SIC_AX.pi4                      ; st0 = y*n          | st1 = x
        fsubp                                   ; st0 = x - y*n = x mod pi/4

        @@.fpu.cw.restore                       ; restore control word
}

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; <- rcx = angle disposition

macro @@xmm0.sin.cos.reduce
{
        mov     rcx, @@.xmm0.sin.cos.reduce
        call    rcx
}

$asproc @@.xmm0.sin.cos.reduce

   .main:
        @@.xmm0.div.mod.pi4                     ; xmm0 = x mod pi/4 | n = x div pi/4

    $ifdef _X64
        test    rcx, rcx                        ; rcx = n
    $else
        test    edx, edx                        ; edx = n.HI
    $end
        jns    .GE.0
   .LT.0:                                       ; n < 0
        xorpd   xmm5, xmm5
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .LT.0.main
        jp     .LT.0.main
   .LT.0.x.EQ.0:                                ; n < 0, x = 0
        add     rcx, 8
        and     rcx, 0x07
        @@.nabs xmm0
        jmp    .return
   .LT.0.main:
        add     rcx, 7
        and     rcx, 0x07
        test    rcx, 1
        jp     .LT.0.p
   .LT.0.np:
        @@.abs  xmm0
        jmp    .return
   .LT.0.p:
        xmovsd  xmm5, SIC_AX.pi4
        addsd   xmm0, xmm5                      ; xmm0 = x + pi/4
        jmp    .return
   .GE.0:                                       ; n >= 0
        and     rcx, 0x07
        test    rcx, 1
        jp     .return
   .update:
        xmovx   xmm5, xmm0
        xmovsd  xmm0, SIC_AX.pi4
        subsd   xmm0, xmm5                      ; xmm0 = pi/4 - x

   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; <- rcx = angle disposition

macro @@xmm0.pi.sin.cos.reduce
{
        mov     rcx, @@.xmm0.pi.sin.cos.reduce
        call    rcx
}

$asproc @@.xmm0.pi.sin.cos.reduce

   .main:
        @@.xmm0.pi.div.mod.pi4                  ; xmm0 = x mod pi/4 | n = x div pi/4

        test    rcx, rcx                        ; rcx = n
        jns    .GE.0
   .LT.0:                                       ; n < 0
        xorpd   xmm5, xmm5
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .LT.0.main
        jp     .LT.0.main
   .LT.0.x.EQ.0:                                ; n < 0, x = 0
        add     rcx, 8
        and     rcx, 0x07
        @@.nabs xmm0
        jmp    .return
   .LT.0.main:
        add     rcx, 7
        and     rcx, 0x07
        test    rcx, 1
        jp     .LT.0.p
   .LT.0.np:
        @@.abs  xmm0
        jmp    .return
   .LT.0.p:
        xmovsd  xmm5, SIC_AX.pi4
        addsd   xmm0, xmm5                      ; xmm0 = x + pi/4
        jmp    .return
   .GE.0:                                       ; n >= 0
        and     rcx, 0x07
        test    rcx, 1
        jp     .return
   .update:
        xmovx   xmm5, xmm0
        xmovsd  xmm0, SIC_AX.pi4
        subsd   xmm0, xmm5                      ; xmm0 = pi/4 - x

   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; <- rcx = angle disposition

macro @@st0.sin.cos.reduce
{
        mov     rcx, @@.st0.sin.cos.reduce
        call    rcx
}

$asproc @@.st0.sin.cos.reduce

   .main:
        @@.st0.div.mod.pi4                      ; st0 = x mod pi/4 | n = x div pi/4

    $ifdef _X64
        test    rcx, rcx                        ; rcx = n
    $else
        test    edx, edx                        ; edx = n.HI
    $end
        jns    .GE.0
   .LT.0:                                       ; n < 0
        ftst                                    ; compare x to 0
        fnjnz  .LT.0.main
   .LT.0.x.EQ.0:                                ; n < 0, x = 0
        add     ecx, 8
        and     ecx, 0x07
        fabs
        fchs
        jmp    .return
   .LT.0.main:
        add     rcx, 7
        and     rcx, 0x07
        test    rcx, 1
        jp     .LT.0.p
   .LT.0.np:
        fabs
        jmp    .return
   .LT.0.p:
        faddq   SIC_AX.pi4                      ; st0 = x + pi/4
        jmp    .return
   .GE.0:                                       ; n >= 0
        and     rcx, 0x07
        test    rcx, 1
        jp     .return
   .update:
        fsubrq  SIC_AX.pi4                      ; st0 = pi/4 - x

   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; <- rcx = angle disposition

macro @@st0.pi.sin.cos.reduce
{
        mov     rcx, @@.st0.pi.sin.cos.reduce
        call    rcx
}

$asproc @@.st0.pi.sin.cos.reduce

   .main:
        @@.st0.pi.div.mod.pi4                   ; st0 = x mod pi/4 | n = x div pi/4

        test    rcx, rcx                        ; rcx = n
        jns    .GE.0
   .LT.0:                                       ; n < 0
        ftst                                    ; compare x to 0
        fnjnz  .LT.0.main
   .LT.0.x.EQ.0:                                ; n < 0, x = 0
        add     ecx, 8
        and     ecx, 0x07
        fabs
        fchs
        jmp    .return
   .LT.0.main:
        add     rcx, 7
        and     rcx, 0x07
        test    rcx, 1
        jp     .LT.0.p
   .LT.0.np:
        fabs
        jmp    .return
   .LT.0.p:
        faddq   SIC_AX.pi4                      ; st0 = x + pi/4
        jmp    .return
   .GE.0:                                       ; n >= 0
        and     rcx, 0x07
        test    rcx, 1
        jp     .return
   .update:
        fsubrq  SIC_AX.pi4                      ; st0 = pi/4 - x

   .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; <- rcx = angle disposition

macro @@xmm0.sec.cosec.reduce
{
        mov     rcx, @@.xmm0.sec.cosec.reduce
        call    rcx
}

$asproc @@.xmm0.sec.cosec.reduce

   .main:
        @@.xmm0.div.mod.pi4                     ; xmm0 = x mod pi/4 | n = x div pi/4

    $ifdef _X64
        test    rcx, rcx                        ; rcx = n
    $else
        test    edx, edx                        ; edx = n.HI
    $end
        jns    .GE.0
   .LT.0:                                       ; n < 0
        xorpd   xmm5, xmm5
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .LT.0.main
        jp     .LT.0.main
   .LT.0.x.EQ.0:                                ; n < 0, x = 0
        add     rcx, 8
        and     rcx, 0x07
        @@.nabs xmm0
        jmp    .return
   .LT.0.main:
        add     rcx, 7
        and     rcx, 0x07
        test    rcx, 1
        jp     .LT.0.p
   .LT.0.np:
        @@.abs  xmm0
        jmp    .return
   .LT.0.p:
        xmovsd  xmm5, SIC_AX.pi4
        addsd   xmm0, xmm5                      ; xmm0 = x + pi/4
        jmp    .return
   .GE.0:                                       ; n >= 0
        and     rcx, 0x07
        test    rcx, 1
        jp     .return
   .update:
        xmovx   xmm5, xmm0
        xmovsd  xmm0, SIC_AX.pi4
        subsd   xmm0, xmm5                      ; xmm0 = pi/4 - x

   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; <- rcx = angle disposition

macro @@xmm0.pi.sec.cosec.reduce
{
        mov     rcx, @@.xmm0.pi.sec.cosec.reduce
        call    rcx
}

$asproc @@.xmm0.pi.sec.cosec.reduce

   .main:
        @@.xmm0.pi.div.mod.pi4                  ; xmm0 = x mod pi/4 | n = x div pi/4

        test    rcx, rcx                        ; rcx = n
        jns    .GE.0
   .LT.0:                                       ; n < 0
        xorpd   xmm5, xmm5
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .LT.0.main
        jp     .LT.0.main
   .LT.0.x.EQ.0:                                ; n < 0, x = 0
        add     rcx, 8
        and     rcx, 0x07
        @@.nabs xmm0
        jmp    .return
   .LT.0.main:
        add     rcx, 7
        and     rcx, 0x07
        test    rcx, 1
        jp     .LT.0.p
   .LT.0.np:
        @@.abs  xmm0
        jmp    .return
   .LT.0.p:
        xmovsd  xmm5, SIC_AX.pi4
        addsd   xmm0, xmm5                      ; xmm0 = x + pi/4
        jmp    .return
   .GE.0:                                       ; n >= 0
        and     rcx, 0x07
        test    rcx, 1
        jp     .return
   .update:
        xmovx   xmm5, xmm0
        xmovsd  xmm0, SIC_AX.pi4
        subsd   xmm0, xmm5                      ; xmm0 = pi/4 - x

   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; <- rcx = angle disposition

macro @@st0.sec.cosec.reduce
{
        mov     rcx, @@.st0.sec.cosec.reduce
        call    rcx
}

$asproc @@.st0.sec.cosec.reduce

   .main:
        @@.st0.div.mod.pi4                      ; st0 = x mod pi/4 | n = x div pi/4

    $ifdef _X64
        test    rcx, rcx                        ; rcx = n
    $else
        test    edx, edx                        ; edx = n.HI
    $end
        jns    .GE.0
   .LT.0:                                       ; n < 0
        ftst                                    ; compare x to 0
        fnjnz  .LT.0.main
   .LT.0.x.EQ.0:                                ; n < 0, x = 0
        add     ecx, 8
        and     ecx, 0x07
        fabs
        fchs
        jmp    .return
   .LT.0.main:
        add     rcx, 7
        and     rcx, 0x07
        test    rcx, 1
        jp     .LT.0.p
   .LT.0.np:
        fabs
        jmp    .return
   .LT.0.p:
        faddq   SIC_AX.pi4                      ; st0 = x + pi/4
        jmp    .return
   .GE.0:                                       ; n >= 0
        and     rcx, 0x07
        test    rcx, 1
        jp     .return
   .update:
        fsubrq  SIC_AX.pi4                      ; st0 = pi/4 - x

   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; <- rcx = angle disposition

macro @@st0.pi.sec.cosec.reduce
{
        mov     rcx, @@.st0.pi.sec.cosec.reduce
        call    rcx
}

$asproc @@.st0.pi.sec.cosec.reduce

   .main:
        @@.st0.pi.div.mod.pi4                   ; st0 = x mod pi/4 | n = x div pi/4

        test    rcx, rcx                        ; rcx = n
        jns    .GE.0
   .LT.0:                                       ; n < 0
        ftst                                    ; compare x to 0
        fnjnz  .LT.0.main
   .LT.0.x.EQ.0:                                ; n < 0, x = 0
        add     ecx, 8
        and     ecx, 0x07
        fabs
        fchs
        jmp    .return
   .LT.0.main:
        add     rcx, 7
        and     rcx, 0x07
        test    rcx, 1
        jp     .LT.0.p
   .LT.0.np:
        fabs
        jmp    .return
   .LT.0.p:
        faddq   SIC_AX.pi4                      ; st0 = x + pi/4
        jmp    .return
   .GE.0:                                       ; n >= 0
        and     rcx, 0x07
        test    rcx, 1
        jp     .return
   .update:
        fsubrq  SIC_AX.pi4                      ; st0 = pi/4 - x

   .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; <- rcx = angle disposition

macro @@xmm0.tan.cotan.reduce
{
        mov     rcx, @@.xmm0.tan.cotan.reduce
        call    rcx
}

$asproc @@.xmm0.tan.cotan.reduce

   .main:
        @@.xmm0.div.mod.pi4                     ; xmm0 = x mod pi/4 | n = x div pi/4

    $ifdef _X64
        test    rcx, rcx                        ; rcx = n
    $else
        test    edx, edx                        ; edx = n.HI
    $end
        jns    .GE.0
   .LT.0:                                       ; n < 0
        xorpd   xmm5, xmm5
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .LT.0.main
        jp     .LT.0.main
   .LT.0.x.EQ.0:                                ; n < 0, x = 0
        add     rcx, 4
        and     rcx, 0x03
        @@.nabs xmm0
        jmp    .return
   .LT.0.main:
        add     rcx, 3
        and     rcx, 0x03
        test    rcx, 1
        jp     .LT.0.p
   .LT.0.np:
        @@.abs  xmm0
        jmp    .return
   .LT.0.p:
        xmovsd  xmm5, SIC_AX.pi4
        addsd   xmm0, xmm5                      ; xmm0 = x + pi/4
        jmp    .return
   .GE.0:                                       ; n >= 0
        and     rcx, 0x03
        test    rcx, 1
        jp     .return
   .update:
        xmovx   xmm5, xmm0
        xmovsd  xmm0, SIC_AX.pi4
        subsd   xmm0, xmm5                      ; xmm0 = pi/4 - x

   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; <- rcx = angle disposition

macro @@xmm0.pi.tan.cotan.reduce
{
        mov     rcx, @@.xmm0.pi.tan.cotan.reduce
        call    rcx
}

$asproc @@.xmm0.pi.tan.cotan.reduce

   .main:
        @@.xmm0.pi.div.mod.pi4                  ; xmm0 = x mod pi/4 | n = x div pi/4

        test    rcx, rcx                        ; rcx = n
        jns    .GE.0
   .LT.0:                                       ; n < 0
        xorpd   xmm5, xmm5
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .LT.0.main
        jp     .LT.0.main
   .LT.0.x.EQ.0:                                ; n < 0, x = 0
        add     rcx, 4
        and     rcx, 0x03
        @@.nabs xmm0
        jmp    .return
   .LT.0.main:
        add     rcx, 3
        and     rcx, 0x03
        test    rcx, 1
        jp     .LT.0.p
   .LT.0.np:
        @@.abs  xmm0
        jmp    .return
   .LT.0.p:
        xmovsd  xmm5, SIC_AX.pi4
        addsd   xmm0, xmm5                      ; xmm0 = x + pi/4
        jmp    .return
   .GE.0:                                       ; n >= 0
        and     rcx, 0x03
        test    rcx, 1
        jp     .return
   .update:
        xmovx   xmm5, xmm0
        xmovsd  xmm0, SIC_AX.pi4
        subsd   xmm0, xmm5                      ; xmm0 = pi/4 - x

   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; <- rcx = angle disposition

macro @@st0.tan.cotan.reduce
{
        mov     rcx, @@.st0.tan.cotan.reduce
        call    rcx
}

$asproc @@.st0.tan.cotan.reduce

   .main:
        @@.st0.div.mod.pi4                      ; st0 = x mod pi/4 | n = x div pi/4

    $ifdef _X64
        test    rcx, rcx                        ; rcx = n
    $else
        test    edx, edx                        ; edx = n.HI
    $end
        jns    .GE.0
   .LT.0:                                       ; n < 0
        ftst                                    ; compare x to 0
        fnjnz  .LT.0.main
   .LT.0.x.EQ.0:                                ; n < 0, x = 0
        add     ecx, 4
        and     ecx, 0x03
        fabs
        fchs
        jmp    .return
   .LT.0.main:
        add     rcx, 3
        and     rcx, 0x03
        test    rcx, 1
        jp     .LT.0.p
   .LT.0.np:
        fabs
        jmp    .return
   .LT.0.p:
        faddq   SIC_AX.pi4                      ; st0 = x + pi/4
        jmp    .return
   .GE.0:                                       ; n >= 0
        and     rcx, 0x03
        test    rcx, 1
        jp     .return
   .update:
        fsubrq  SIC_AX.pi4                      ; st0 = pi/4 - x

   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; <- rcx = angle disposition

macro @@st0.pi.tan.cotan.reduce
{
        mov     rcx, @@.st0.pi.tan.cotan.reduce
        call    rcx
}

$asproc @@.st0.pi.tan.cotan.reduce

   .main:
        @@.st0.pi.div.mod.pi4                   ; st0 = x mod pi/4 | n = x div pi/4

        test    rcx, rcx                        ; rcx = n
        jns    .GE.0
   .LT.0:                                       ; n < 0
        ftst                                    ; compare x to 0
        fnjnz  .LT.0.main
   .LT.0.x.EQ.0:                                ; n < 0, x = 0
        add     ecx, 4
        and     ecx, 0x03
        fabs
        fchs
        jmp    .return
   .LT.0.main:
        add     rcx, 3
        and     rcx, 0x03
        test    rcx, 1
        jp     .LT.0.p
   .LT.0.np:
        fabs
        jmp    .return
   .LT.0.p:
        faddq   SIC_AX.pi4                      ; st0 = x + pi/4
        jmp    .return
   .GE.0:                                       ; n >= 0
        and     rcx, 0x03
        test    rcx, 1
        jp     .return
   .update:
        fsubrq  SIC_AX.pi4                      ; st0 = pi/4 - x

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

macro @@sin.arg.sse
{
$asprocf @@sin.arg

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
        mov     edx, ecx
        shr     edx, 32-12
        cmp     edx, 1023+TG.arg.max.exp
        jb     .return                          ; return if |x| < 2^TG.arg.max.exp

   .max:                                        ; |x| >= max_arg
        xorpd   xmm0, xmm0                      ; +0.0
        test    cx, 0x8000                      ; test sign flag
        jz     .assign                          ; jump if x > 0
   .min_arg:
        @@.chs  xmm0                            ; -0.0
        jmp    .assign

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

macro @@sin.arg.fpu
{
$asprocf @@sin.arg

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
        mov     edx, ecx
        shr     edx, 32-12
        cmp     edx, 1023+TG.arg.max.exp
        jb     .return                          ; return if |x| < 2^TG.arg.max.exp

   .max:                                        ; |x| >= max_arg
        fstp    st0
        fldz                                    ; +0.0
        test    cx, 0x8000                      ; test sign flag
        jz     .assign                          ; jump if x > 0
   .min_arg:
        fchs                                    ; -0.0
        jmp    .assign

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
  @@sin.arg.sse
$else
  @@sin.arg.fpu
$end

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get sinpi for some args
;
; sinpi(+0)   = +0
; sinpi(-0)   = -0
; sinpi(NaN)  = NaN
; sinpi(PInf) = +0
; sinpi(NInf) = -0

; <- rbx - assign result flag

macro @@sinpi.arg.sse
{
$asprocf @@sinpi.arg

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

macro @@sinpi.arg.fpu
{
$asprocf @@sinpi.arg

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
  @@sinpi.arg.sse
$else
  @@sinpi.arg.fpu
$end

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; rcx = angle disposition
; rax = sin function
; rdx = cos function

$asprocf @@sin.pn

        test    rcx, rcx
        jz     .n0
        dec     rcx
        jz     .n1
        dec     rcx
        jz     .n2
        dec     rcx
        jz     .n3
        dec     rcx
        jz     .n4
        dec     rcx
        jz     .n5
        dec     rcx
        jz     .n6
;       dec     rcx
;       jz     .n7

   .n7:                                         ; sin(2*pi-x0) = -sin(x0)
   .n4:                                         ; sin(pi+x0)   = -sin(x0)
        call    rax
    $ifdef _SSEX
        @@.chs  xmm0
    $else
        fchs
    $end
        jmp    .return

   .n6:                                         ; sin(3*pi/2+x0) = -cos(x0)
   .n5:                                         ; sin(3*pi/2-x0) = -cos(x0)
        call    rdx
    $ifdef _SSEX
        @@.chs  xmm0
    $else
        fchs
    $end
        jmp    .return

   .n2:                                         ; sin(pi/2+x0) = cos(x0)
   .n1:                                         ; sin(pi/2-x0) = cos(x0)
;       call    rdx
;       jmp    .return
        mov     rax, rdx

   .n3:                                         ; sin(pi-x0) = sin(x0)
   .n0:
        call    rax
   .return:
        retn
$endp

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

macro @@cos.arg.sse
{
$asprocf @@cos.arg

        @@.xmm0.flags.exp.ecx                   ; ecx = flags and exponent
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x0002                      ; test infinity flag
        jnz    .Inf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        shr     ecx, 32-12
        cmp     ecx, 1023+TG.arg.max.exp
        jb     .return                          ; return if |x| < 2^TG.arg.max.exp

   .max:                                        ; |x| >= max_arg
        xmovsd  xmm0, SIC_AX.1.0
        jmp    .assign

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

macro @@cos.arg.fpu
{
$asprocf @@cos.arg

        @@.st0.flags.exp.ecx                    ; ecx = flags and exponent
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x0002                      ; test infinity flag
        jnz    .Inf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        shr     ecx, 32-12
        cmp     ecx, 1023+TG.arg.max.exp
        jb     .return                          ; return if |x| < 2^TG.arg.max.exp

   .max:                                        ; |x| >= max_arg
        fstp    st0
        fld1
        jmp    .assign

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
  @@cos.arg.sse
$else
  @@cos.arg.fpu
$end

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get cospi for some args
;
; cospi(+0)   = 1
; cospi(-0)   = 1
; cospi(NaN)  = NaN
; cospi(PInf) = 1
; cospi(NInf) = 1

; <- rbx - assign result flag

macro @@cospi.arg.sse
{
$asprocf @@cospi.arg

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

macro @@cospi.arg.fpu
{
$asprocf @@cospi.arg

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
  @@cospi.arg.sse
$else
  @@cospi.arg.fpu
$end

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; rcx = angle disposition
; rax = cos function
; rdx = sin function

$asprocf @@cos.pn

        test    rcx, rcx
        jz     .n0
        dec     rcx
        jz     .n1
        dec     rcx
        jz     .n2
        dec     rcx
        jz     .n3
        dec     rcx
        jz     .n4
        dec     rcx
        jz     .n5
        dec     rcx
        jz     .n6
;       dec     rcx
;       jz     .n7
        jmp    .n7

   .n6:                                         ; cos(3*pi/2+x0) = sin(x0)
   .n1:                                         ; cos(pi/2-x0)   = sin(x0)
        call    rdx
        jmp    .return

   .n5:                                         ; cos(3*pi/2-x0) = -sin(x0)
   .n2:                                         ; cos(pi/2+x0)   = -sin(x0)
        call    rdx
    $ifdef _SSEX
        @@.chs  xmm0
    $else
        fchs
    $end
        jmp    .return

   .n4:                                         ; cos(pi+x0) = -cos(x0)
   .n3:                                         ; cos(pi-x0) = -cos(x0)
        call    rax
    $ifdef _SSEX
        @@.chs  xmm0
    $else
        fchs
    $end
        jmp    .return

   .n7:                                         ; cos(2*pi-x0) = cos(x0)
   .n0:
        call    rax
   .return:
        retn
$endp

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

macro @@sincos.arg.sse
{
$asprocf @@sincos.arg

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
        jnz    .NaN

   .main:
        mov     edx, ecx
        shr     edx, 32-12
        cmp     edx, 1023+TG.arg.max.exp
        jb     .return                          ; return if |x| < 2^TG.arg.max.exp

   .max:                                        ; |x| >= max_arg
        xorpd   xmm0, xmm0                      ; sin = +0.0
        xmovsd  xmm1, SIC_AX.1.0                ; cos = 1.0
        test    cx, 0x8000                      ; test sign flag
        jz     .assign                          ; jump if x > 0
   .min_arg:
        @@.chs  xmm0                            ; sin = -0.0
        jmp    .assign

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
        xmovx   xmm1, xmm0
        jmp    .assign

   .Zero:                                       ; x = 0 = xmm0
;       xmovx   xmm0, xmm0                      ; sin = 0
        xmovsd  xmm1, SIC_AX.1.0                ; cos = 1
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

macro @@sincos.arg.fpu
{
$asprocf @@sincos.arg

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
        jnz    .NaN

   .main:
        mov     edx, ecx
        shr     edx, 32-12
        cmp     edx, 1023+TG.arg.max.exp
        jb     .return                          ; return if |x| < 2^TG.arg.max.exp

   .max:                                        ; |x| >= max_arg
        fstp    st0
        test    cx, 0x8000                      ; test sign flag
        jz     .max_arg                         ; jump if x > 0
   .min_arg:
        fldz
        fchs
        fld1                                    ; st0 = cos = 1.0  | st1 = sin = -0.0
        jmp    .assign
   .max_arg:
        fldz
        fld1                                    ; st0 = cos = 1.0  | st1 = sin = +0.0
        jmp    .assign

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
  @@sincos.arg.sse
$else
  @@sincos.arg.fpu
$end

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get sinpi & cospi for some args
;
; sinpi(+0)   = +0
; sinpi(-0)   = -0
; sinpi(NaN)  = NaN
; sinpi(PInf) = +0
; sinpi(NInf) = -0
;
; cospi(+0)   = 1
; cospi(-0)   = 1
; cospi(NaN)  = NaN
; cospi(PInf) = 1
; cospi(NInf) = 1

; <- rbx - assign result flag

macro @@sincospi.arg.sse
{
$asprocf @@sincospi.arg

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
        xmovx   xmm1, xmm0
        jmp    .assign

   .Zero:                                       ; x = 0 = xmm0
;       xmovx   xmm0, xmm0                      ; sin = 0
        xmovsd  xmm1, SIC_AX.1.0                ; cos = 1
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

macro @@sincospi.arg.fpu
{
$asprocf @@sincospi.arg

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
  @@sincospi.arg.sse
$else
  @@sincospi.arg.fpu
$end

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; return_1 = st1 = sin
; return_2 = st0 = cos

; rcx = angle disposition
; rax = sincos function

$asprocf @@sincos.pn

        call    rax                             ; xmm0 = sin | xmm1 = cos
                                                ; st0  = cos | st1  = sin
        test    rcx, rcx
        jz     .n0
        dec     rcx
        jz     .n1
        dec     rcx
        jz     .n2
        dec     rcx
        jz     .n3
        dec     rcx
        jz     .n4
        dec     rcx
        jz     .n5
        dec     rcx
        jz     .n6
;       dec     rcx
;       jz     .n7

    $ifdef _SSEX                                ; xmm0 = sin | xmm1 = cos

   .n7:                                         ; sin(2*pi-x0)   = -sin(x0) : xmm0
        @@.chs  xmm0                            ; cos(2*pi-x0)   =  cos(x0) : xmm1
        jmp    .return                          ; xmm0 = -sin | xmm1 = cos

   .n6:                                         ; sin(3*pi/2+x0) = -cos(x0) : xmm0
        @@.chs  xmm1                            ; cos(3*pi/2+x0) =  sin(x0) : xmm1
        jmp    .xch                             ; xmm0 = sin | xmm1 = -cos

   .n5:                                         ; sin(3*pi/2-x0) = -cos(x0) : xmm0
        @@.chss xmm0, xmm1                      ; cos(3*pi/2-x0) = -sin(x0) : xmm1
        jmp    .xch                             ; xmm0 = -sin | xmm1 = -cos

   .n4:                                         ; sin(pi+x0)     = -sin(x0) : xmm0
        @@.chss xmm0, xmm1                      ; cos(pi+x0)     = -cos(x0) : xmm1
        jmp    .return                          ; xmm0 = -sin | xmm1 = -cos

   .n3:                                         ; sin(pi-x0)     =  sin(x0) : xmm0
        @@.chs  xmm1                            ; cos(pi-x0)     = -cos(x0) : xmm1
        jmp    .return                          ; xmm0 = sin | xmm1 = -cos

   .n2:                                         ; sin(pi/2+x0)   =  cos(x0) : xmm0
        @@.chs  xmm0                            ; cos(pi/2+x0)   = -sin(x0) : xmm1
;       jmp    .xch                             ; xmm0 = -sin | xmm1 = cos

   .xch:
   .n1:                                         ; sin(pi/2-x0)   =  cos(x0) : xmm0
        @@.xch  xmm0, xmm1                      ; cos(pi/2-x0)   =  sin(x0) : xmm1

    $else                                       ; st0 = cos | st1 = sin

   .n7:                                         ; sin(2*pi-x0)   = -sin(x0) : st1
        fxch                                    ; cos(2*pi-x0)   =  cos(x0) : st0
        fchs
        jmp    .xch                             ; st0 = -sin | st1 = cos

   .n6:                                         ; sin(3*pi/2+x0) = -cos(x0) : st1
        fchs                                    ; cos(3*pi/2+x0) =  sin(x0) : st0
        jmp    .xch                             ; st0 = -cos | st1 = sin

   .n5:                                         ; sin(3*pi/2-x0) = -cos(x0) : st1
        fchs                                    ; cos(3*pi/2-x0) = -sin(x0) : st0
        fxch
        fchs
        jmp    .return                          ; st0 = -sin | st1 = -cos

   .n4:                                         ; sin(pi+x0)     = -sin(x0) : st1
        fchs                                    ; cos(pi+x0)     = -cos(x0) : st0
        fxch
        fchs
        jmp    .xch                             ; st0 = -sin | st1 = -cos

   .n3:                                         ; sin(pi-x0)     =  sin(x0) : st1
        fchs                                    ; cos(pi-x0)     = -cos(x0) : st0
        jmp    .return                          ; st0 = -cos | st1 = sin

   .n2:                                         ; sin(pi/2+x0)   =  cos(x0) : st1
        fxch                                    ; cos(pi/2+x0)   = -sin(x0) : st0
        fchs
        jmp    .return                          ; st0 = -sin | st1 = cos

   .xch:
   .n1:                                         ; sin(pi/2-x0)   =  cos(x0) : st1
        fxch                                    ; cos(pi/2-x0)   =  sin(x0) : st0

    $end

   .n0:
   .return:
        retn
$endp

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

macro @@cossin.arg.sse
{
$asprocf @@cossin.arg

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
        jnz    .NaN

   .main:
        mov     edx, ecx
        shr     edx, 32-12
        cmp     edx, 1023+TG.arg.max.exp
        jb     .return                          ; return if |x| < 2^TG.arg.max.exp

   .max:                                        ; |x| >= max_arg
        xmovsd  xmm0, SIC_AX.1.0                ; cos = 1.0
        xorpd   xmm1, xmm1                      ; sin = +0.0
        test    cx, 0x8000                      ; test sign flag
        jz     .assign                          ; jump if x > 0
   .min_arg:
        @@.chs  xmm1                            ; sin = -0.0
        jmp    .assign

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
        xmovx   xmm1, xmm0
        jmp    .assign

   .Zero:                                       ; x = 0 = xmm0
        xmovx   xmm1, xmm0                      ; sin = 0
        xmovsd  xmm0, SIC_AX.1.0                ; cos = 1
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

macro @@cossin.arg.fpu
{
$asprocf @@cossin.arg

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
        jnz    .NaN

   .main:
        mov     edx, ecx
        shr     edx, 32-12
        cmp     edx, 1023+TG.arg.max.exp
        jb     .return                          ; return if |x| < 2^TG.arg.max.exp

   .max:                                        ; |x| >= max_arg
        fstp    st0
        fld1
        fldz                                    ; st0 = sin = +0.0 | st1 = cos = 1
        test    cx, 0x8000                      ; test sign flag
        jz     .assign                          ; jump if x > 0
   .min_arg:
        fchs                                    ; st0 = sin = -0.0 | st1 = cos = 1
        jmp    .assign

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
  @@cossin.arg.sse
$else
  @@cossin.arg.fpu
$end

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get cospi & sinpi for some args
;
; cospi(+0)   = 1
; cospi(-0)   = 1
; cospi(NaN)  = NaN
; cospi(PInf) = 1
; cospi(NInf) = 1
;
; sinpi(+0)   = +0
; sinpi(-0)   = -0
; sinpi(NaN)  = NaN
; sinpi(PInf) = +0
; sinpi(NInf) = -0

; <- rbx - assign result flag

macro @@cossinpi.arg.sse
{
$asprocf @@cossinpi.arg

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
        xmovx   xmm1, xmm0
        jmp    .assign

   .Zero:                                       ; x = 0 = xmm0
        xmovx   xmm1, xmm0                      ; sin = 0
        xmovsd  xmm0, SIC_AX.1.0                ; cos = 1
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

macro @@cossinpi.arg.fpu
{
$asprocf @@cossinpi.arg

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
  @@cossinpi.arg.sse
$else
  @@cossinpi.arg.fpu
$end

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; return_1 = st1 = cos
; return_2 = st0 = sin

; rcx = angle disposition
; rax = cossin function

$asprocf @@cossin.pn

        call    rax                             ; xmm0 = cos | xmm1 = sin
                                                ; st0  = sin | st1  = cos
        test    rcx, rcx
        jz     .n0
        dec     rcx
        jz     .n1
        dec     rcx
        jz     .n2
        dec     rcx
        jz     .n3
        dec     rcx
        jz     .n4
        dec     rcx
        jz     .n5
        dec     rcx
        jz     .n6
;       dec     rcx
;       jz     .n7

    $ifdef _SSEX                                ; xmm0 = cos | xmm1 = sin

   .n7:                                         ; cos(2*pi-x0)   =  cos(x0) : xmm0
        @@.chs  xmm1                            ; sin(2*pi-x0)   = -sin(x0) : xmm1
        jmp    .return                          ; xmm0 = cos | xmm1 = -sin

   .n6:                                         ; cos(3*pi/2+x0) =  sin(x0) : xmm0
        @@.chs  xmm0                            ; sin(3*pi/2+x0) = -cos(x0) : xmm1
        jmp    .xch                             ; xmm0 = -cos | xmm1 = sin

   .n5:                                         ; cos(3*pi/2-x0) = -sin(x0) : xmm0
        @@.chss xmm0, xmm1                      ; sin(3*pi/2-x0) = -cos(x0) : xmm1
        jmp    .xch                             ; xmm0 = -cos | xmm1 = -sin

   .n4:                                         ; cos(pi+x0)     = -cos(x0) : xmm0
        @@.chss xmm0, xmm1                      ; sin(pi+x0)     = -sin(x0) : xmm1
        jmp    .return                          ; xmm0 = -cos | xmm1 = -sin

   .n3:                                         ; cos(pi-x0)     = -cos(x0) : xmm0
        @@.chs  xmm0                            ; sin(pi-x0)     =  sin(x0) : xmm1
        jmp    .return                          ; xmm0 = -cos | xmm1 = sin

   .n2:                                         ; cos(pi/2+x0)   = -sin(x0) : xmm0
        @@.chs  xmm1                            ; sin(pi/2+x0)   =  cos(x0) : xmm1
;       jmp    .xch                             ; xmm0 = cos | xmm1 = -sin

   .xch:
   .n1:                                         ; cos(pi/2-x0)   =  sin(x0) : xmm0
        @@.xch  xmm0, xmm1                      ; sin(pi/2-x0)   =  cos(x0) : xmm1

    $else                                       ; st0 = sin | st1 = cos

   .n7:                                         ; cos(2*pi-x0)   =  cos(x0) : st1
        fchs                                    ; sin(2*pi-x0)   = -sin(x0) : st0
        jmp    .return                          ; st0 = -sin | st1 = cos

   .n6:                                         ; cos(3*pi/2+x0) =  sin(x0) : st1
        fxch                                    ; sin(3*pi/2+x0) = -cos(x0) : st0
        fchs
        jmp    .return                          ; st0 = -cos | st1 = sin

   .n5:                                         ; cos(3*pi/2-x0) = -sin(x0) : st1
        fchs                                    ; sin(3*pi/2-x0) = -cos(x0) : st0
        fxch
        fchs
        jmp    .return                          ; st0 = -cos | st1 = -sin

   .n4:                                         ; cos(pi+x0)     = -cos(x0) : st1
        fchs                                    ; sin(pi+x0)     = -sin(x0) : st0
        fxch
        fchs
        jmp    .xch                             ; st0 = -cos | st1 = -sin

   .n3:                                         ; cos(pi-x0)     = -cos(x0) : st1
        fxch                                    ; sin(pi-x0)     =  sin(x0) : st0
        fchs
        jmp    .xch                             ; st0 = -cos | st1 = sin

   .n2:                                         ; cos(pi/2+x0)   = -sin(x0) : st1
        fchs                                    ; sin(pi/2+x0)   =  cos(x0) : st0
;       jmp    .xch                             ; st0 = -sin | st1 = cos

   .xch:
   .n1:                                         ; cos(pi/2-x0)   =  sin(x0) : st1
        fxch                                    ; sin(pi/2-x0)   =  cos(x0) : st0

    $end

   .n0:
   .return:
        retn
$endp

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

macro @@sec.arg.sse
{
$asprocf @@sec.arg

        @@.xmm0.flags.exp.ecx                   ; ecx = flags and exponent
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x0002                      ; test infinity flag
        jnz    .Inf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        shr     ecx, 32-12
        cmp     ecx, 1023+TG.arg.max.exp
        jb     .return                          ; return if |x| < 2^TG.arg.max.exp

   .max:                                        ; |x| >= max_arg
;       xmovsd  xmm0, SIC_AX.1.0
;       jmp    .assign

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

macro @@sec.arg.fpu
{
$asprocf @@sec.arg

        @@.st0.flags.exp.ecx                    ; ecx = flags and exponent
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x0002                      ; test infinity flag
        jnz    .Inf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        shr     ecx, 32-12
        cmp     ecx, 1023+TG.arg.max.exp
        jb     .return                          ; return if |x| < 2^TG.arg.max.exp

   .max:                                        ; |x| >= max_arg
;       fstp    st0
;       fld1
;       jmp    .assign

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
  @@sec.arg.sse
$else
  @@sec.arg.fpu
$end

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get secpi for some args
;
; secpi(+0)   = 1
; secpi(-0)   = 1
; secpi(NaN)  = NaN
; secpi(PInf) = 1
; secpi(NInf) = 1

; <- rbx - assign result flag

macro @@secpi.arg.sse
{
$asprocf @@secpi.arg

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

macro @@secpi.arg.fpu
{
$asprocf @@secpi.arg

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
  @@secpi.arg.sse
$else
  @@secpi.arg.fpu
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

macro @@cosec.arg.sse
{
$asprocf @@cosec.arg

        @@.xmm0.flags.exp.ecx                   ; ecx = flags and exponent
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x0002                      ; test infinity flag
        jnz    .assign                          ; f(Inf) = Inf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        mov     edx, ecx
        shr     edx, 32-12
        cmp     edx, 1023-356
        jb     .eps                             ; jump if |x| < 2^(-356)
        cmp     edx, 1023+TG.arg.max.exp
        jb     .return                          ; return if |x| < 2^TG.arg.max.exp

   .max:                                        ; |x| >= max_arg
        test    cx, 0x8000                      ; test sign flag
        jz     .max_arg
   .min_arg:
        xmovsd  xmm0, SIC_AX.NInf
        jmp    .assign
   .max_arg:
        xmovsd  xmm0, SIC_AX.PInf
        jmp    .assign

   .eps:                                        ; |x| < 2^(-356) | cosec(x) = 1/x + x/6
        xmovsd  xmm5, SIC_AX.1.0
        divsd   xmm5, xmm0                      ; xmm5 = 1/x
        xmovsd  xmm4, SIC_AX.1D6
        mulsd   xmm0, xmm4                      ; xmm0 = x/6
        addsd   xmm0, xmm5                      ; xmm0 = 1/x + x/6
        jmp    .assign

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

macro @@cosec.arg.fpu
{
$asprocf @@cosec.arg

        @@.st0.flags.exp.ecx                    ; ecx = flags and exponent
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x0002                      ; test infinity flag
        jnz    .assign                          ; f(Inf) = Inf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        mov     edx, ecx
        shr     edx, 32-12
        cmp     edx, 1023-356
        jb     .eps                             ; jump if |x| < 2^(-356)
        cmp     edx, 1023+TG.arg.max.exp
        jb     .return                          ; return if |x| < 2^TG.arg.max.exp

   .max:                                        ; |x| >= max_arg
        fstp    st0
        test    cx, 0x8000                      ; test sign flag
        jz     .max_arg
   .min_arg:
        fldq    SIC_AX.NInf
        jmp    .assign
   .max_arg:
        fldq    SIC_AX.PInf
        jmp    .assign

   .eps:                                        ; |x| < 2^(-356) | cosec(x) = 1/x + x/6
        fld     st0
        fmulq   SIC_AX.1D6
        fxch                                    ; st0 = x | st1 = x/6
        fld1
        fdivrp
        faddp                                   ; st0 = 1/x + x/6
        jmp    .assign

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
  @@cosec.arg.sse
$else
  @@cosec.arg.fpu
$end

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get cosecpi for some args
;
; cosecpi(+0)   = PInf
; cosecpi(-0)   = NInf
; cosecpi(NaN)  = NaN
; cosecpi(PInf) = PInf
; cosecpi(NInf) = NInf

; <- rbx - assign result flag

macro @@cosecpi.arg.sse
{
$asprocf @@cosecpi.arg

        @@.xmm0.flags.exp.ecx                   ; ecx = flags and exponent
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x0002                      ; test infinity flag
        jnz    .assign                          ; f(Inf) = Inf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        shr     ecx, 32-12
        cmp     ecx, 1023-358
        jae    .return                          ; jump if |x| >= 2^(-358)

   .eps:                                        ; |x| < 2^(-358) | cosecpi(x) = cosec(pi*x) = 1/(pi*x) + (pi*x)/6
        xmovsd  xmm5, SIC_AX.pi
        mulsd   xmm0, xmm5                      ; xmm0 = pi*x = x'
        xmovsd  xmm5, SIC_AX.1.0
        divsd   xmm5, xmm0                      ; xmm5 = 1/x'
        xmovsd  xmm4, SIC_AX.1D6
        mulsd   xmm0, xmm4                      ; xmm0 = x'/6
        addsd   xmm0, xmm5                      ; xmm0 = 1/x' + x'/6
        jmp    .assign

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

macro @@cosecpi.arg.fpu
{
$asprocf @@cosecpi.arg

        @@.st0.flags.exp.ecx                    ; ecx = flags and exponent
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x0002                      ; test infinity flag
        jnz    .assign                          ; f(Inf) = Inf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        shr     ecx, 32-12
        cmp     ecx, 1023-358
        jae    .return                          ; jump if |x| >= 2^(-358)

   .eps:                                        ; |x| < 2^(-358) | cosecpi(x) = cosec(pi*x) = 1/(pi*x) + (pi*x)/6
        fldpi
        fmulp                                   ; st0 = pi*x = x'
        fld     st0
        fmulq   SIC_AX.1D6
        fxch                                    ; st0 = x' | st1 = x'/6
        fld1
        fdivrp
        faddp                                   ; st0 = 1/x' + x'/6
        jmp    .assign

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
  @@cosecpi.arg.sse
$else
  @@cosecpi.arg.fpu
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

macro @@tan.arg.sse
{
$asprocf @@tan.arg

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
        mov     edx, ecx
        shr     edx, 32-12
        cmp     edx, 1023+TG.arg.max.exp
        jb     .return                          ; return if |x| < 2^TG.arg.max.exp

   .max:                                        ; |x| >= max_arg
        xorpd   xmm0, xmm0                      ; +0.0
        test    cx, 0x8000                      ; test sign flag
        jz     .assign                          ; jump if x > 0
   .min_arg:
        @@.chs  xmm0                            ; -0.0
        jmp    .assign

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

macro @@tan.arg.fpu
{
$asprocf @@tan.arg

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
        mov     edx, ecx
        shr     edx, 32-12
        cmp     edx, 1023+TG.arg.max.exp
        jb     .return                          ; return if |x| < 2^TG.arg.max.exp

   .max:                                        ; |x| >= max_arg
        fstp    st0
        fldz                                    ; +0.0
        test    cx, 0x8000                      ; test sign flag
        jz     .assign                          ; jump if x > 0
   .min_arg:
        fchs                                    ; -0.0
        jmp    .assign

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
  @@tan.arg.sse
$else
  @@tan.arg.fpu
$end

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get tanpi for some args
;
; tanpi(+0)   = +0
; tanpi(-0)   = -0
; tanpi(NaN)  = NaN
; tanpi(PInf) = +0
; tanpi(NInf) = -0

; <- rbx - assign result flag

macro @@tanpi.arg.sse
{
$asprocf @@tanpi.arg

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

macro @@tanpi.arg.fpu
{
$asprocf @@tanpi.arg

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
  @@tanpi.arg.sse
$else
  @@tanpi.arg.fpu
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

macro @@cotan.arg.sse
{
$asprocf @@cotan.arg

        @@.xmm0.flags.exp.ecx                   ; ecx = flags and exponent
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x0002                      ; test infinity flag
        jnz    .assign                          ; f(Inf) = Inf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        mov     edx, ecx
        shr     edx, 32-12
        cmp     edx, 1023-356
        jb     .eps                             ; jump if |x| < 2^(-356)
        cmp     edx, 1023+TG.arg.max.exp
        jb     .return                          ; return if |x| < 2^TG.arg.max.exp

   .max:                                        ; |x| >= max_arg
        test    cx, 0x8000                      ; test sign flag
        jz     .max_arg
   .min_arg:
        xmovsd  xmm0, SIC_AX.NInf
        jmp    .assign
   .max_arg:
        xmovsd  xmm0, SIC_AX.PInf
        jmp    .assign

   .eps:                                        ; |x| < 2^(-356) | cotan(x) = 1/x - x/3
        xmovsd  xmm5, SIC_AX.1.0
        divsd   xmm5, xmm0                      ; xmm5 = 1/x
        xmovsd  xmm4, SIC_AX.m1D3
        mulsd   xmm0, xmm4                      ; xmm0 = -x/3
        addsd   xmm0, xmm5                      ; xmm0 = 1/x - x/3
        jmp    .assign

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

macro @@cotan.arg.fpu
{
$asprocf @@cotan.arg

        @@.st0.flags.exp.ecx                    ; ecx = flags and exponent
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x0002                      ; test infinity flag
        jnz    .assign                          ; f(Inf) = Inf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        mov     edx, ecx
        shr     edx, 32-12
        cmp     edx, 1023-356
        jb     .eps                             ; jump if |x| < 2^(-356)
        cmp     edx, 1023+TG.arg.max.exp
        jb     .return                          ; return if |x| < 2^TG.arg.max.exp

   .max:                                        ; |x| >= max_arg
        fstp    st0
        test    cx, 0x8000                      ; test sign flag
        jz     .max_arg
   .min_arg:
        fldq    SIC_AX.NInf
        jmp    .assign
   .max_arg:
        fldq    SIC_AX.PInf
        jmp    .assign

   .eps:                                        ; |x| < 2^(-356) | cotan(x) = 1/x - x/3
        fld     st0
        fmulq   SIC_AX.m1D3
        fxch                                    ; st0 = x | st1 = -x/3
        fld1
        fdivrp
        faddp                                   ; st0 = 1/x - x/3
        jmp    .assign

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
  @@cotan.arg.sse
$else
  @@cotan.arg.fpu
$end

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get cotanpi for some args
;
; cotanpi(+0)   = PInf
; cotanpi(-0)   = NInf
; cotanpi(NaN)  = NaN
; cotanpi(PInf) = PInf
; cotanpi(NInf) = NInf

; <- rbx - assign result flag

macro @@cotanpi.arg.sse
{
$asprocf @@cotanpi.arg

        @@.xmm0.flags.exp.ecx                   ; ecx = flags and exponent
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x0002                      ; test infinity flag
        jnz    .assign                          ; f(Inf) = Inf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        shr     ecx, 32-12
        cmp     ecx, 1023-358
        jae    .return                          ; jump if |x| >= 2^(-358)

   .eps:                                        ; |x| < 2^(-358) | cotanpi(x) = cotan(pi*x) = 1/(pi*x) - (pi*x)/3
        xmovsd  xmm5, SIC_AX.pi
        mulsd   xmm0, xmm5                      ; xmm0 = pi*x = x'
        xmovsd  xmm5, SIC_AX.1.0
        divsd   xmm5, xmm0                      ; xmm5 = 1/x'
        xmovsd  xmm4, SIC_AX.m1D3
        mulsd   xmm0, xmm4                      ; xmm0 = -x'/3
        addsd   xmm0, xmm5                      ; xmm0 = 1/x' - x'/3
        jmp    .assign

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

macro @@cotanpi.arg.fpu
{
$asprocf @@cotanpi.arg

        @@.st0.flags.exp.ecx                    ; ecx = flags and exponent
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x0002                      ; test infinity flag
        jnz    .assign                          ; f(Inf) = Inf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        shr     ecx, 32-12
        cmp     ecx, 1023-358
        jae    .return                          ; jump if |x| >= 2^(-358)

   .eps:                                        ; |x| < 2^(-358) | cotanpi(x) = cotan(pi*x) = 1/(pi*x) - (pi*x)/3
        fldpi
        fmulp                                   ; st0 = pi*x = x'
        fld     st0
        fmulq   SIC_AX.m1D3
        fxch                                    ; st0 = x' | st1 = -x'/3
        fld1
        fdivrp
        faddp                                   ; st0 = 1/x' - x'/3
        jmp    .assign

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
  @@cotanpi.arg.sse
$else
  @@cotanpi.arg.fpu
$end

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; rcx = angle disposition
; rax = tan function

; 0 : 0*pi/4 <= x < 1*pi/4      x = x0
; 1 : 1*pi/4 <= x < 2*pi/4      x = pi/2 - x0
; 2 : 2*pi/4 <= x < 3*pi/4      x = pi/2 + x0
; 3 : 3*pi/4 <= x < 4*pi/4      x = pi - x0

$asprocf @@ftan.pn

        call    rax                             ; xmm0 = tan
                                                ; st0  = tan
        test    rcx, rcx
        jz     .n0
        dec     rcx
        jz     .n1
        dec     rcx
        jz     .n2
;       dec     rcx
;       jz     .n3

    $ifdef _SSEX                                ; xmm0 = tan

   .n3:                                         ; tan(pi - x0) = -tan(x0)
        jmp    .chs
   .n2:                                         ; tan(pi/2 + x0) = -1/tan(x0)
        xmovx   xmm5, xmm0
        xmovsd  xmm0, SIC_AX.1.0
        divsd   xmm0, xmm5
        jmp    .chs
   .n1:                                         ; tan(pi/2 - x0) = 1/tan(x0)
        xmovx   xmm5, xmm0
        xmovsd  xmm0, SIC_AX.1.0
        divsd   xmm0, xmm5
        jmp    .return

   .chs:
        @@.chs  xmm0

    $else                                       ; st0 = tan

   .n3:                                         ; tan(pi - x0) = -tan(x0)
        jmp    .chs
   .n2:                                         ; tan(pi/2 + x0) = -1/tan(x0)
        fld1
        fdivrp
        jmp    .chs
   .n1:                                         ; tan(pi/2 - x0) = 1/tan(x0)
        fld1
        fdivrp
        jmp    .return

   .chs:
        fchs

    $end

   .n0:
   .return:
        retn
$endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

$asprocf @@fcotan.pn

        call    rax                             ; xmm0 = tan
                                                ; st0  = tan
        test    rcx, rcx
        jz     .n0
        dec     rcx
;       jz     .n1
        jz     .return
        dec     rcx
        jz     .n2
;       dec     rcx
;       jz     .n3

    $ifdef _SSEX                                ; xmm0 = tan

   .n3:                                         ; cotan(pi - x0) = -1/tan(x0)
        xmovx   xmm5, xmm0
        xmovsd  xmm0, SIC_AX.1.0
        divsd   xmm0, xmm5
        jmp    .chs
   .n2:                                         ; cotan(pi/2 + x0) = -tan(x0)
        jmp    .chs
   .n1:                                         ; cotan(pi/2 - x0) = tan(x0)
;       jmp    .return
   .n0:                                         ; cotan(x0) = 1/tan(x0)
        xmovx   xmm5, xmm0
        xmovsd  xmm0, SIC_AX.1.0
        divsd   xmm0, xmm5
        jmp    .return

   .chs:
        @@.chs  xmm0

    $else                                       ; st0 = tan

   .n3:                                         ; cotan(pi - x0) = -1/tan(x0)
        fld1
        fdivrp
        jmp    .chs
   .n2:                                         ; cotan(pi/2 + x0) = -tan(x0)
        jmp    .chs
   .n1:                                         ; cotan(pi/2 - x0) = tan(x0)
;       jmp    .return
   .n0:                                         ; cotan(x0) = 1/tan(x0)
        fld1
        fdivrp
        jmp    .return

   .chs:
        fchs

    $end

   .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; inverse sine

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get asin for some args
;
; asin(+0)    = +0
; asin(-0)    = -0
; asin(NaN)   = NaN
; asin(PInf)  = NaN
; asin(NInf)  = NaN
;
; asin(+1)    = +pi/2 (-)
; asin(-1)    = -pi/2 (-)
; asin(|x|>1) = NaN

; <- rbx - assign result flag

macro @@asin.arg.sse
{
$asprocf @@asin.arg

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
        xmovx   xmm3, xmm0
        @@.abs  xmm3                            ; xmm3 = |x|
        xmovsd  xmm5, SIC_AX.1.0                ; xmm5 = 1.0
        comisd  xmm3, xmm5                      ; compare |x| to 1.0
        jbe    .return                          ; jump if |x| <= 1.0

   .Inf:                                        ; x = Infinity
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

macro @@asin.arg.fpu
{
$asprocf @@asin.arg

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
        fld     st0
        fabs                                    ; st0 = |x|
        fld1
        fcompp                                  ; compare 1.0 to |x|
        fnjge  .return                          ; jump if |x| <= 1.0 (1.0 >= |x|)

   .Inf:                                        ; x = Infinity
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
  @@asin.arg.sse
$else
  @@asin.arg.fpu
$end

; ------------------------------------------------------------------------------

; inverse cosine

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get acos for some args
;
; acos(0)     = pi/2
; acos(NaN)   = NaN
; acos(PInf)  = NaN
; acos(NInf)  = NaN
;
; acos(+1)    = +0 (-)
; acos(-1)    = pi (-)
; acos(|x|>1) = NaN

; <- rbx - assign result flag

macro @@acos.arg.sse
{
$asprocf @@acos.arg

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
        xmovx   xmm3, xmm0
        @@.abs  xmm3                            ; xmm3 = |x|
        xmovsd  xmm5, SIC_AX.1.0                ; xmm5 = 1.0
        comisd  xmm3, xmm5                      ; compare |x| to 1.0
        jbe    .return                          ; jump if |x| <= 1.0

   .Inf:                                        ; x = Infinity
   .assign.NaN:
        xmovsd  xmm0, SIC_AX.NaN
        jmp    .assign

   .Zero:                                       ; x = 0
   .assign.pi2:
        xmovsd  xmm0, SIC_AX.pi2
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

macro @@acos.arg.fpu
{
$asprocf @@acos.arg

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
        fld     st0
        fabs                                    ; st0 = |x|
        fld1
        fcompp                                  ; compare 1.0 to |x|
        fnjge  .return                          ; jump if |x| <= 1.0 (1.0 >= |x|)

   .Inf:                                        ; x = Infinity
   .assign.NaN:
        fstp    st0
        fldq    SIC_AX.NaN
        jmp    .assign

   .Zero:                                       ; x = 0
   .assign.pi2:
        fstp    st0
        fldq    SIC_AX.pi2
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@acos.arg.sse
$else
  @@acos.arg.fpu
$end

; ------------------------------------------------------------------------------

; inverse secant

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get asec for some args
;
; asec(0)     = NaN
; asec(NaN)   = NaN
; asec(PInf)  = pi/2
; asec(NInf)  = pi/2
;
; asec(+1)    = +0
; asec(-1)    = pi
; asec(|x|<1) = NaN

; <- rbx - assign result flag

macro @@asec.arg.sse
{
$asprocf @@asec.arg

        @@.xmm0.flags.exp.ecx                   ; ecx = flags and exponent
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x0002                      ; test infinity flag
        jnz    .Inf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        shr     ecx, 32-12
        cmp     ecx, 1023+53
        jb     .X?                              ; continue if |x| < 2^53

   .max:                                        ; |x| >= max_arg
        xmovsd  xmm0, SIC_AX.pi2                ; pi/2
        jmp    .assign

   .X?:
        xmovsd  xmm5, SIC_AX.1.0                ; xmm5 = 1.0
        comisd  xmm0, xmm5                      ; compare x to 1.0
        jb     .X.LT.1.0                        ; jump if x < 1.0
   .X.GE.1.0:                                   ; x >= 1.0
        ja     .return                          ; jump if x > 1.0
   .X.EQ.1.0:                                   ; x = 1.0
        xorpd   xmm0, xmm0                      ; +0.0
        jmp    .assign
   .X.LT.1.0:                                   ; x < 1.0
        @@.chs  xmm5                            ; xmm5 = -1.0
        comisd  xmm0, xmm5                      ; compare x to -1.0
        jbe    .X.LE.m1.0                       ; jump if x <= -1.0
   .X.GT.m1.0:                                  ; -1.0 < x < 1.0
        xmovsd  xmm0, SIC_AX.NaN                ; NaN
        jmp    .assign
   .X.LE.m1.0:                                  ; x <= -1.0
        jb     .return                          ; jump if x < -1.0
   .X.EQ.m1.0:                                  ; x = -1.0
        xmovsd  xmm0, SIC_AX.pi                 ; pi
        jmp    .assign

   .Inf:                                        ; x = Infinity
        xmovsd  xmm0, SIC_AX.pi2                ; pi/2
        jmp    .assign

   .Zero:                                       ; x = 0
        xmovsd  xmm0, SIC_AX.NaN                ; NaN
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

macro @@asec.arg.fpu
{
$asprocf @@asec.arg

        @@.st0.flags.exp.ecx                    ; ecx = flags and exponent
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        test    cx, 0x0002                      ; test infinity flag
        jnz    .Inf
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        shr     ecx, 32-12
        cmp     ecx, 1023+53
        jb     .X?                              ; continue if |x| < 2^53

   .max:                                        ; |x| >= max_arg
        fstp    st0
        fldq    SIC_AX.pi2                      ; pi/2
        jmp    .assign

   .X?:
        fld1
        fcomp                                   ; compare 1.0 to x
        fnstsw  ax
        sahf
        ja     .X.LT.1.0                        ; jump if x < 1.0 (1.0 > x)
   .X.GE.1.0:                                   ; x >= 1.0
        jb     .return                          ; jump if x > 1.0 (1.0 < x)
   .X.EQ.1.0:                                   ; x = 1.0
        fstp    st0
        fldz                                    ; +0.0
        jmp    .assign
   .X.LT.1.0:                                   ; x < 1.0
        fld1
        fchs
        fcomp                                   ; compare -1.0 to x
        fnstsw  ax
        sahf
        jae    .X.LE.m1.0                       ; jump if x <= -1.0 (-1.0 >= x)
   .X.GT.m1.0:                                  ; -1.0 < x < 1.0
        fstp    st0
        fldq    SIC_AX.NaN                      ; NaN
        jmp    .assign
   .X.LE.m1.0:                                  ; x <= -1.0
        ja     .return                          ; jump if x < -1.0 (-1.0 > x)
   .X.EQ.m1.0:                                  ; x = -1.0
        fstp    st0
        fldpi                                   ; pi
        jmp    .assign

   .Inf:                                        ; x = Infinity
        fstp    st0
        fldq    SIC_AX.pi2                      ; pi/2
        jmp    .assign

   .Zero:                                       ; x = 0
        fstp    st0
        fldq    SIC_AX.NaN                      ; NaN
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@asec.arg.sse
$else
  @@asec.arg.fpu
$end

; ------------------------------------------------------------------------------

; inverse cosecant

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get acosec for some args
;
; acosec(0)     = NaN
; acosec(NaN)   = NaN
; acosec(PInf)  = +0
; acosec(NInf)  = -0
;
; acosec(+1)    = +pi/2
; acosec(-1)    = -pi/2
; acosec(|x|<1) = NaN

; <- rbx - assign result flag

macro @@acosec.arg.sse
{
$asprocf @@acosec.arg

        @@.xmm0.flags.exp.ecx                   ; ecx = flags
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
        mov     edx, ecx
        shr     edx, 32-12
        cmp     edx, 1023+53
        jb     .X?                              ; continue if |x| < 2^53

   .max:                                        ; |x| >= max_arg
        test    cx, 0x8000                      ; test sign flag
        jz     .max_arg
   .min_arg:
        xorpd   xmm0, xmm0
        @@.chs  xmm0                            ; -0.0
        jmp    .assign
   .max_arg:
        xorpd   xmm0, xmm0                      ; +0.0
        jmp    .assign

   .X?:
        xmovsd  xmm5, SIC_AX.1.0                ; xmm5 = 1.0
        comisd  xmm0, xmm5                      ; compare x to 1.0
        jb     .X.LT.1.0                        ; jump if x < 1.0
   .X.GE.1.0:                                   ; x >= 1.0
        ja     .return                          ; jump if x > 1.0
   .X.EQ.1.0:                                   ; x = 1.0
        xmovsd  xmm0, SIC_AX.pi2                ; +pi/2
        jmp    .assign
   .X.LT.1.0:                                   ; x < 1.0
        @@.chs  xmm5                            ; xmm5 = -1.0
        comisd  xmm0, xmm5                      ; compare x to -1.0
        jbe    .X.LE.m1.0                       ; jump if x <= -1.0
   .X.GT.m1.0:                                  ; -1.0 < x < 1.0
        xmovsd  xmm0, SIC_AX.NaN                ; NaN
        jmp    .assign
   .X.LE.m1.0:                                  ; x <= -1.0
        jb     .return                          ; jump if x < -1.0
   .X.EQ.m1.0:                                  ; x = -1.0
        xmovsd  xmm0, SIC_AX.mpi2               ; -pi/2
        jmp    .assign

   .NInf:                                       ; x = Negative Infinity
        xorpd   xmm0, xmm0
        @@.chs  xmm0                            ; -0.0
        jmp    .assign

   .PInf:                                       ; x = Positive Infinity
        xorpd   xmm0, xmm0                      ; +0.0
        jmp    .assign

   .Zero:                                       ; x = 0
        xmovsd  xmm0, SIC_AX.NaN                ; NaN
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

macro @@acosec.arg.fpu
{
$asprocf @@acosec.arg

        @@.st0.flags.exp.ecx                    ; ecx = flags
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
        mov     edx, ecx
        shr     edx, 32-12
        cmp     edx, 1023+53
        jb     .X?                              ; continue if |x| < 2^53

   .max:                                        ; |x| >= max_arg
        fstp    st0
        test    cx, 0x8000                      ; test sign flag
        jz     .max_arg
   .min_arg:
        fldz
        fchs                                    ; -0.0
        jmp    .assign
   .max_arg:
        fldz                                    ; +0.0
        jmp    .assign

   .X?:
        fld1
        fcomp                                   ; compare 1.0 to x
        fnstsw  ax
        sahf
        ja     .X.LT.1.0                        ; jump if x < 1.0 (1.0 > x)
   .X.GE.1.0:                                   ; x >= 1.0
        jb     .return                          ; jump if x > 1.0 (1.0 < x)
   .X.EQ.1.0:                                   ; x = 1.0
        fstp    st0
        fldq    SIC_AX.pi2                      ; +pi/2
        jmp    .assign
   .X.LT.1.0:                                   ; x < 1.0
        fld1
        fchs
        fcomp                                   ; compare -1.0 to x
        fnstsw  ax
        sahf
        jae    .X.LE.m1.0                       ; jump if x <= -1.0 (-1.0 >= x)
   .X.GT.m1.0:                                  ; -1.0 < x < 1.0
        fstp    st0
        fldq    SIC_AX.NaN                      ; NaN
        jmp    .assign
   .X.LE.m1.0:                                  ; x <= -1.0
        ja     .return                          ; jump if x < -1.0 (-1.0 > x)
   .X.EQ.m1.0:                                  ; x = -1.0
        fstp    st0
        fldq    SIC_AX.mpi2                     ; -pi/2
        jmp    .assign

   .NInf:                                       ; x = Negative Infinity
        fstp    st0
        fldz
        fchs                                    ; -0.0
        jmp    .assign

   .PInf:                                       ; x = Positive Infinity
        fstp    st0
        fldz                                    ; +0.0
        jmp    .assign

   .Zero:                                       ; x = 0
        fstp    st0
        fldq    SIC_AX.NaN                      ; NaN
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@acosec.arg.sse
$else
  @@acosec.arg.fpu
$end

; ------------------------------------------------------------------------------

; inverse tangent

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get atan for some args
;
; atan(+0)   = +0
; atan(-0)   = -0
; atan(NaN)  = NaN
; atan(PInf) = +pi/2
; atan(NInf) = -pi/2

; <- rbx - assign result flag

macro @@atan.arg.sse
{
$asprocf @@atan.arg

        @@.xmm0.flags.exp.ecx                   ; ecx = flags and exponent
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        cmp     cx, 0x0002                      ; is positive infinity?
        je     .assign.pi2
        cmp     cx, 0x8002                      ; is negative infinity?
        je     .assign.mpi2
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        test    cx, 0x8000                      ; test sign flag
        jz     .GT.Zero

   .LT.Zero:                                    ; x < 0
        shr     ecx, 32-12
        cmp     ecx, 1023+53
        jb     .return

   .assign.mpi2:                                ; x <= -(2^53)
        xmovsd  xmm0, SIC_AX.mpi2               ; atan = -pi/2
        jmp    .assign

   .GT.Zero:                                    ; x > 0
        shr     ecx, 32-12
        cmp     ecx, 1023+53
        jb     .return

   .assign.pi2:                                 ; x >= +(2^53)
        xmovsd  xmm0, SIC_AX.pi2                ; atan = +pi/2
;       jmp    .assign

   .Zero:                                       ; x = 0
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

macro @@atan.arg.fpu
{
$asprocf @@atan.arg

        @@.st0.flags.exp.ecx                    ; ecx = flags and exponent
        test    cx, 0x0007                      ; test any flag
        jz     .main
        test    cx, 0x0001                      ; test zero flag
        jnz    .Zero
        cmp     cx, 0x0002                      ; is positive infinity?
        je     .assign.pi2
        cmp     cx, 0x8002                      ; is negative infinity?
        je     .assign.mpi2
        test    cx, 0x0004                      ; test nan flag
        jnz    .assign                          ; f(NaN) = NaN

   .main:
        test    cx, 0x8000                      ; test sign flag
        jz     .GT.Zero

   .LT.Zero:                                    ; x < 0
        shr     ecx, 32-12
        cmp     ecx, 1023+53
        jb     .return

   .assign.mpi2:                                ; x <= -(2^53)
        fstp    st0
        fldq    SIC_AX.mpi2                     ; atan = -pi/2
        jmp    .assign

   .GT.Zero:                                    ; x > 0
        shr     ecx, 32-12
        cmp     ecx, 1023+53
        jb     .return

   .assign.pi2:                                 ; x >= +(2^53)
        fstp    st0
        fldq    SIC_AX.pi2                      ; atan = +pi/2
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
  @@atan.arg.sse
$else
  @@atan.arg.fpu
$end

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get atan2 for some args

; 0x0000'8000 - sign flag
; 0x0000'0001 - zero flag
; 0x0000'0002 - infinity flag
; 0x0000'0004 - nan flag

; If x and y are both zero, domain error does not occur
; If x and y are both zero, range error does not occur either
; If y is zero, pole error does not occur
;
; If y is �0   and x is negative or -0, 켗I is returned
; If y is �0   and x is positive or +0, �0 is returned
;
; If y is 켲nf and x is finite, 켗I/2 is returned
; If y is 켲nf and x is -inf, �3PI/4 is returned
; If y is 켲nf and x is +inf, 켗I/4 is returned
;
; If x is �0   and y is negative, -PI/2 is returned
; If x is �0   and y is positive, +PI/2 is returned
;
; If x is -inf and y is finite and positive, +PI is returned
; If x is -inf and y is finite and negative, -PI is returned
;
; If x is +inf and y is finite and positive, +0 is returned
; If x is +inf and y is finite and negative, -0 is returned
;
; If either x is NaN or y is NaN, NaN is returned

; atan2(y,x) = atan(y/x)
; y = xmm0
; x = xmm1

; <- rbx - assign result flag

macro @@atan2.arg.sse
{
$asprocf @@atan2.arg

        mov     rdi, SIC_AX.0.0

        @@.xmm0.flags.ecx                       ; ecx = y flags
        @@.xmm1.flags.edx                       ; edx = x flags

        test    cx, 0x0007
        jnz    .main
        test    dx, 0x0007
        jz     .x.y

   .main:
        test    cx, 0x0004
        jnz    .y.NaN
        test    dx, 0x0004
        jnz    .x.NaN

        test    cx, 0x0001
        jnz    .y.Zero
        test    cx, 0x0002
        jnz    .y.Inf
        test    dx, 0x0001
        jnz    .x.Zero
        test    dx, 0x0002
        jnz    .x.Inf

   .y.NotNaN:                                   ; y <> NaN
   .x.NotNaN:                                   ; x <> NaN
   .y.NotZero:                                  ; y <> 0
   .y.NotInf:                                   ; y <> Inf
   .x.NotZero:                                  ; x <> 0
   .x.NotInf:                                   ; x <> Inf

   .x.y:
        test    dx, dx
        jns    .return
   .x.Neg:
        test    cx, cx
        jns    .x.Neg.y.Pos
   .x.Neg.y.Neg:
        mov     rdi, SIC_AX.mpi
        jmp    .return
   .x.Neg.y.Pos:
        mov     rdi, SIC_AX.pi
        jmp    .return

   .x.Zero:                                     ; x = ?0
        test    cx, 0x8000
        jz     .x.Zero.y.Pos
   .x.Zero.y.Neg:                               ; x = ?0, y = Neg : -pi/2
        xmovsd  xmm0, SIC_AX.mpi2
        jmp    .assign
   .x.Zero.y.Pos:                               ; x = ?0, y = Pos : +pi/2
        xmovsd  xmm0, SIC_AX.pi2
        jmp    .assign

   .x.Inf:                                      ; x = ?Inf
        test    dx, 0x8000
        jz     .x.PInf
   .x.NInf:
        test    cx, 0x8000
        jz     .x.NInf.y.Pos
   .x.NInf.y.Neg:                               ; x = -Inf, y = Neg : -pi
        xmovsd  xmm0, SIC_AX.mpi
        jmp    .assign
   .x.NInf.y.Pos:                               ; x = -Inf, y = Pos : +pi
        xmovsd  xmm0, SIC_AX.pi
        jmp    .assign
   .x.PInf:
        test    cx, 0x8000
        jz     .x.PInf.y.Pos
   .x.PInf.y.Neg:                               ; x = +Inf, y = Neg : -0
        xorpd   xmm0, xmm0
        @@.chs  xmm0
;       xmovsd  xmm0, SIC_AX.m0.0
        jmp    .assign
   .x.PInf.y.Pos:                               ; x = +Inf, y = Pos : +0
        xorpd   xmm0, xmm0
        jmp    .assign

   .y.Zero:                                     ; y = ?0
        test    cx, 0x8000
        jz     .y.PZero
   .y.NZero:                                    ; y = -0
        test    dx, 0x8000
        jz     .y.NZero.x.Pos
   .y.NZero.x.Neg:                              ; y = -0, x = Neg : -pi
        xmovsd  xmm0, SIC_AX.mpi
        jmp    .assign
   .y.NZero.x.Pos:                              ; y = -0, x = Pos : -0
        xorpd   xmm0, xmm0
        @@.chs  xmm0
;       xmovsd  xmm0, SIC_AX.m0.0
        jmp    .assign
   .y.PZero:                                    ; y = +0
        test    dx, 0x8000
        jz     .y.PZero.x.Pos
   .y.PZero.x.Neg:                              ; y = +0, x = Neg : +pi
        xmovsd  xmm0, SIC_AX.pi
        jmp    .assign
   .y.PZero.x.Pos:                              ; y = +0, x = Pos : +0
        xorpd   xmm0, xmm0
        jmp    .assign

   .y.Inf:                                      ; y = ?Inf
        test    cx, 0x8000
        jz     .y.PInf
   .y.NInf:                                     ; y = -Inf
        test    dx, 0x0002
        jnz    .y.NInf.x.Inf
   .y.NInf.x.NotInf:                            ; y = -Inf, x = Fin : -pi/2
        xmovsd  xmm0, SIC_AX.mpi2
        jmp    .assign
   .y.NInf.x.Inf:
        test    dx, 0x8000
        jz     .y.NInf.x.PInf
   .y.NInf.x.NInf:                              ; y = -Inf, x = -Inf : -3pi/4
        xmovsd  xmm0, SIC_AX.m3pi4
        jmp    .assign
   .y.NInf.x.PInf:                              ; y = -Inf, x = +Inf : -pi/4
        xmovsd  xmm0, SIC_AX.mpi4
        jmp    .assign
   .y.PInf:                                     ; y = +Inf
        test    dx, 0x0002
        jnz    .y.PInf.x.Inf
   .y.PInf.x.NotInf:                            ; y = +Inf, x = Fin : +pi/2
        xmovsd  xmm0, SIC_AX.pi2
        jmp    .assign
   .y.PInf.x.Inf:
        test    dx, 0x8000
        jz     .y.PInf.x.PInf
   .y.PInf.x.NInf:                              ; y = +Inf, x = -Inf : +3pi/4
        xmovsd  xmm0, SIC_AX.3pi4
        jmp    .assign
   .y.PInf.x.PInf:                              ; y = +Inf, x = +Inf : +pi/4
        xmovsd  xmm0, SIC_AX.pi4
        jmp    .assign

   .x.NaN:                                      ; x = Not a Number
   .y.NaN:                                      ; y = Not a Number
        xmovsd  xmm0, SIC_AX.NaN
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

; atan2(y,x) = atan(y/x)
; y = st1
; x = st0

; <- rbx - assign result flag

macro @@atan2.arg.fpu
{
$asprocf @@atan2.arg

        mov     rdi, SIC_AX.0.0

        @@.st0.flags.edx                        ; edx = x flags
        fxch
        @@.st0.flags.ecx                        ; ecx = y flags
        fxch

        test    cx, 0x0007
        jnz    .main
        test    dx, 0x0007
        jz     .x.y

   .main:
        test    cx, 0x0004
        jnz    .y.NaN
        test    dx, 0x0004
        jnz    .x.NaN

        test    cx, 0x0001
        jnz    .y.Zero
        test    cx, 0x0002
        jnz    .y.Inf
        test    dx, 0x0001
        jnz    .x.Zero
        test    dx, 0x0002
        jnz    .x.Inf

   .y.NotNaN:                                   ; y <> NaN
   .x.NotNaN:                                   ; x <> NaN
   .y.NotZero:                                  ; y <> 0
   .y.NotInf:                                   ; y <> Inf
   .x.NotZero:                                  ; x <> 0
   .x.NotInf:                                   ; x <> Inf

   .x.y:
        test    dx, dx
        jns    .return
   .x.Neg:
        test    cx, cx
        jns    .x.Neg.y.Pos
   .x.Neg.y.Neg:
        mov     rdi, SIC_AX.mpi
        jmp    .return
   .x.Neg.y.Pos:
        mov     rdi, SIC_AX.pi
        jmp    .return

   .x.Zero:                                     ; x = ?0
        test    cx, 0x8000
        jz     .x.Zero.y.Pos
   .x.Zero.y.Neg:                               ; x = ?0, y = Neg : -pi/2
        fldq    SIC_AX.mpi2
        jmp    .assign
   .x.Zero.y.Pos:                               ; x = ?0, y = Pos : +pi/2
        fldq    SIC_AX.pi2
        jmp    .assign

   .x.Inf:                                      ; x = ?Inf
        test    dx, 0x8000
        jz     .x.PInf
   .x.NInf:
        test    cx, 0x8000
        jz     .x.NInf.y.Pos
   .x.NInf.y.Neg:                               ; x = -Inf, y = Neg : -pi
        fldpi
        fchs
;       fldq    SIC_AX.mpi
        jmp    .assign
   .x.NInf.y.Pos:                               ; x = -Inf, y = Pos : +pi
        fldpi
        jmp    .assign
   .x.PInf:
        test    cx, 0x8000
        jz     .x.PInf.y.Pos
   .x.PInf.y.Neg:                               ; x = +Inf, y = Neg : -0
        fldz
        fchs
;       fldq    SIC_AX.m0.0
        jmp    .assign
   .x.PInf.y.Pos:                               ; x = +Inf, y = Pos : +0
        fldz
        jmp    .assign

   .y.Zero:                                     ; y = ?0
        test    cx, 0x8000
        jz     .y.PZero
   .y.NZero:                                    ; y = -0
        test    dx, 0x8000
        jz     .y.NZero.x.Pos
   .y.NZero.x.Neg:                              ; y = -0, x = Neg : -pi
        fldpi
        fchs
;       fldq    SIC_AX.mpi
        jmp    .assign
   .y.NZero.x.Pos:                              ; y = -0, x = Pos : -0
        fldz
        fchs
;       fldq    SIC_AX.m0.0
        jmp    .assign
   .y.PZero:                                    ; y = +0
        test    dx, 0x8000
        jz     .y.PZero.x.Pos
   .y.PZero.x.Neg:                              ; y = +0, x = Neg : +pi
        fldpi
        jmp    .assign
   .y.PZero.x.Pos:                              ; y = +0, x = Pos : +0
        fldz
        jmp    .assign

   .y.Inf:                                      ; y = ?Inf
        test    cx, 0x8000
        jz     .y.PInf
   .y.NInf:                                     ; y = -Inf
        test    dx, 0x0002
        jnz    .y.NInf.x.Inf
   .y.NInf.x.NotInf:                            ; y = -Inf, x = Fin : -pi/2
        fldq    SIC_AX.mpi2
        jmp    .assign
   .y.NInf.x.Inf:
        test    dx, 0x8000
        jz     .y.NInf.x.PInf
   .y.NInf.x.NInf:                              ; y = -Inf, x = -Inf : -3pi/4
        fldq    SIC_AX.m3pi4
        jmp    .assign
   .y.NInf.x.PInf:                              ; y = -Inf, x = +Inf : -pi/4
        fldq    SIC_AX.mpi4
        jmp    .assign
   .y.PInf:                                     ; y = +Inf
        test    dx, 0x0002
        jnz    .y.PInf.x.Inf
   .y.PInf.x.NotInf:                            ; y = +Inf, x = Fin : +pi/2
        fldq    SIC_AX.pi2
        jmp    .assign
   .y.PInf.x.Inf:
        test    dx, 0x8000
        jz     .y.PInf.x.PInf
   .y.PInf.x.NInf:                              ; y = +Inf, x = -Inf : +3pi/4
        fldq    SIC_AX.3pi4
        jmp    .assign
   .y.PInf.x.PInf:                              ; y = +Inf, x = +Inf : +pi/4
        fldq    SIC_AX.pi4
        jmp    .assign

   .x.NaN:                                      ; x = Not a Number
   .y.NaN:                                      ; y = Not a Number
        fldq    SIC_AX.NaN
;       jmp    .assign

   .assign:
        fstp    st1
        fstp    st1
        xor     rbx, rbx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@atan2.arg.sse
$else
  @@atan2.arg.fpu
$end

; ------------------------------------------------------------------------------

; inverse cotangent

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; get acotan for some args
;
; acotan(+0)   = +pi/2
; acotan(-0)   = -pi/2
; acotan(NaN)  = NaN
; acotan(PInf) = +0
; acotan(NInf) = -0

; <- rbx - assign result flag

macro @@acotan.arg.sse
{
$asprocf @@acotan.arg

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
        cmp     ecx, 1023+53
        jb     .return
        cmp     ecx, 1023+101
        jb     .x.2P53
        cmp     ecx, 1023+508
        jb     .x.2P101
   .x.2P508:                                    ; |x| >= 2^508 | acotan(x) = 1/x
        xmovx   xmm5, xmm0
        xmovsd  xmm0, SIC_AX.1.0
        divsd   xmm0, xmm5
        jmp    .assign
   .x.2P101:                                    ; |x| >= 2^101
        mov     rbx, 2
        jmp    .return
   .x.2P53:                                     ; |x| >= 2^53
        mov     rbx, 1
        jmp    .return

   .NInf:                                       ; Negative Infinity
   .assign.NZero:
        xorpd   xmm0, xmm0
        @@.chs  xmm0                            ; acotan = -0
        jmp    .assign

   .PInf:                                       ; Positive Infinity
   .assign.PZero:
        xorpd   xmm0, xmm0                      ; acotan = +0
        jmp    .assign

   .Zero:                                       ; x = 0
        test    cx, 0x8000                      ; test sign flag
        jz     .PZero
   .NZero:                                      ; x = -0
        xmovsd  xmm0, SIC_AX.mpi2               ; acotan = -pi/2
        jmp    .assign
   .PZero:                                      ; x = +0
        xmovsd  xmm0, SIC_AX.pi2                ; acotan = +pi/2
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

macro @@acotan.arg.fpu
{
$asprocf @@acotan.arg

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
        cmp     ecx, 1023+53
        jb     .return
        cmp     ecx, 1023+101
        jb     .x.2P53
        cmp     ecx, 1023+508
        jb     .x.2P101
   .x.2P508:                                    ; |x| >= 2^508 | acotan(x) = 1/x
        fld1
        fdivrp
        jmp    .assign
   .x.2P101:                                    ; |x| >= 2^101
        mov     rbx, 2
        jmp    .return
   .x.2P53:                                     ; |x| >= 2^53
        mov     rbx, 1
        jmp    .return

   .NInf:                                       ; Negative Infinity
   .assign.NZero:
        fstp    st0
        fldz
        fchs                                    ; acotan = -0
        jmp    .assign

   .PInf:                                       ; Positive Infinity
   .assign.PZero:
        fstp    st0
        fldz                                    ; acotan = +0
        jmp    .assign

   .Zero:                                       ; x = 0
        fstp    st0
        test    cx, 0x8000                      ; test sign flag
        jz     .PZero
   .NZero:                                      ; x = -0
        fldq    SIC_AX.mpi2                     ; acotan = -pi/2
        jmp    .assign
   .PZero:                                      ; x = +0
        fldq    SIC_AX.pi2                      ; acotan = +pi/2
;       jmp    .assign

   .assign:
        xor     rbx, rbx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@acotan.arg.sse
$else
  @@acotan.arg.fpu
$end

; ------------------------------------------------------------------------------
