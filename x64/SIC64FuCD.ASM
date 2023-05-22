
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (conditional functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; conditional function
; double ie.true ( double x, double T, double F )
; x = rsp
; T = rsp + 8
; F = rsp + 16
;
; returns: T, x <> 0
;          F, x = 0

macro @@ie.true.sse
{
$usprocf @@ie.true

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .T                               ; jump if x <> 0
        jp     .T                               ; jump if x <> 0

    .F: movsd   xmm0, qword [rsp + 16]          ; return F, x = 0
        jmp    .return
    .T: movsd   xmm0, qword [rsp + 8]           ; return T, x <> 0

    .return:
        retn
$endp
}

macro @@ie.true.fpu
{
$usprocf @@ie.true

        fld     qword [rsp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        ftst                                    ; compare x to 0
        fstp    st0
        fnjnz  .T                               ; jump if x <> 0

    .F: fld     qword [rsp + 16]                ; return F, x = 0
        jmp    .return
    .T: fld     qword [rsp + 8]                 ; return T, x <> 0

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@ie.true.sse
$else
  @@ie.true.fpu
$end

; ------------------------------------------------------------------------------

; conditional function
; double ie.false ( double x, double T, double F )
; x = rsp
; T = rsp + 8
; F = rsp + 16
;
; returns: T, x = 0
;          F, x <> 0

macro @@ie.false.sse
{
$usprocf @@ie.false

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .F                               ; jump if x <> 0
        jp     .F                               ; jump if x <> 0

    .T: movsd   xmm0, qword [rsp + 8]           ; return T, x = 0
        jmp    .return
    .F: movsd   xmm0, qword [rsp + 16]          ; return F, x <> 0

    .return:
        retn
$endp
}

macro @@ie.false.fpu
{
$usprocf @@ie.false

        fld     qword [rsp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        ftst                                    ; compare x to 0
        fstp    st0
        fnjz   .T                               ; jump if x = 0

    .F: fld     qword [rsp + 16]                ; return F, x <> 0
        jmp    .return
    .T: fld     qword [rsp + 8]                 ; return T, x = 0

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@ie.false.sse
$else
  @@ie.false.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; conditional function
; double ie.z ( double x, double T, double F )
; x = rsp
; T = rsp + 8
; F = rsp + 16
;
; returns: T, x = 0
;          F, x <> 0

macro @@ie.z.sse
{
$usprocf @@ie.z

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .F                               ; jump if x <> 0
        jp     .F                               ; jump if x <> 0

    .T: movsd   xmm0, qword [rsp + 8]           ; return T, x = 0
        jmp    .return
    .F: movsd   xmm0, qword [rsp + 16]          ; return F, x <> 0

    .return:
        retn
$endp
}

macro @@ie.z.fpu
{
$usprocf @@ie.z

        fld     qword [rsp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        ftst                                    ; compare x to 0
        fstp    st0
        fnje   .T                               ; jump if x = 0

    .F: fld     qword [rsp + 16]                ; return F, x <> 0
        jmp    .return
    .T: fld     qword [rsp + 8]                 ; return T, x = 0

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@ie.z.sse
$else
  @@ie.z.fpu
$end

; ------------------------------------------------------------------------------

; conditional function
; double ie.nz ( double x, double T, double F )
; x = rsp
; T = rsp + 8
; F = rsp + 16
;
; returns: T, x <> 0
;          F, x = 0

macro @@ie.nz.sse
{
$usprocf @@ie.nz

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .T                               ; jump if x <> 0
        jp     .T                               ; jump if x <> 0

    .F: movsd   xmm0, qword [rsp + 16]          ; return F, x = 0
        jmp    .return
    .T: movsd   xmm0, qword [rsp + 8]           ; return T, x <> 0

    .return:
        retn
$endp
}

macro @@ie.nz.fpu
{
$usprocf @@ie.nz

        fld     qword [rsp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        ftst                                    ; compare x to 0
        fstp    st0
        fnjne  .T                               ; jump if x <> 0

    .F: fld     qword [rsp + 16]                ; return F, x = 0
        jmp    .return
    .T: fld     qword [rsp + 8]                 ; return T, x <> 0

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@ie.nz.sse
$else
  @@ie.nz.fpu
$end

; ------------------------------------------------------------------------------

; conditional function
; double ie.az ( double x, double T, double F )
; x = rsp
; T = rsp + 8
; F = rsp + 16
;
; returns: T, x > 0
;          F, x <= 0

macro @@ie.az.sse
{
$usprocf @@ie.az

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        comisd  xmm0, xmm5                      ; compare x to 0
        ja     .T                               ; jump if x > 0

    .F: movsd   xmm0, qword [rsp + 16]          ; return F, x <= 0
        jmp    .return
    .T: movsd   xmm0, qword [rsp + 8]           ; return T, x > 0

    .return:
        retn
$endp
}

macro @@ie.az.fpu
{
$usprocf @@ie.az

        fld     qword [rsp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        ftst                                    ; compare x to 0
        fstp    st0
        fnjg   .T                               ; jump if x > 0

    .F: fld     qword [rsp + 16]                ; return F, x <= 0
        jmp    .return
    .T: fld     qword [rsp + 8]                 ; return T, x > 0

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@ie.az.sse
$else
  @@ie.az.fpu
$end

; ------------------------------------------------------------------------------

; conditional function
; double ie.aez ( double x, double T, double F )
; x = rsp
; T = rsp + 8
; F = rsp + 16
;
; returns: T, x >= 0
;          F, x < 0

macro @@ie.aez.sse
{
$usprocf @@ie.aez

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        comisd  xmm0, xmm5                      ; compare x to 0
        jae    .T                               ; jump if x >= 0

    .F: movsd   xmm0, qword [rsp + 16]          ; return F, x < 0
        jmp    .return
    .T: movsd   xmm0, qword [rsp + 8]           ; return T, x >= 0

    .return:
        retn
$endp
}

macro @@ie.aez.fpu
{
$usprocf @@ie.aez

        fld     qword [rsp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        ftst                                    ; compare x to 0
        fstp    st0
        fnjge  .T                               ; jump if x >= 0

    .F: fld     qword [rsp + 16]                ; return F, x < 0
        jmp    .return
    .T: fld     qword [rsp + 8]                 ; return T, x >= 0

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@ie.aez.sse
$else
  @@ie.aez.fpu
$end

; ------------------------------------------------------------------------------

; conditional function
; double ie.bz ( double x, double T, double F )
; x = rsp
; T = rsp + 8
; F = rsp + 16
;
; returns: T, x < 0
;          F, x >= 0

macro @@ie.bz.sse
{
$usprocf @@ie.bz

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        comisd  xmm0, xmm5                      ; compare x to 0
        jb     .T                               ; jump if x < 0

    .F: movsd   xmm0, qword [rsp + 16]          ; return F, x >= 0
        jmp    .return
    .T: movsd   xmm0, qword [rsp + 8]           ; return T, x < 0

    .return:
        retn
$endp
}

macro @@ie.bz.fpu
{
$usprocf @@ie.bz

        fld     qword [rsp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        ftst                                    ; compare x to 0
        fstp    st0
        fnjl   .T                               ; jump if x < 0

    .F: fld     qword [rsp + 16]                ; return F, x >= 0
        jmp    .return
    .T: fld     qword [rsp + 8]                 ; return T, x < 0

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@ie.bz.sse
$else
  @@ie.bz.fpu
$end

; ------------------------------------------------------------------------------

; conditional function
; double ie.bez ( double x, double T, double F )
; x = rsp
; T = rsp + 8
; F = rsp + 16
;
; returns: T, x <= 0
;          F, x > 0

macro @@ie.bez.sse
{
$usprocf @@ie.bez

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        comisd  xmm0, xmm5                      ; compare x to 0
        jbe    .T                               ; jump if x <= 0

    .F: movsd   xmm0, qword [rsp + 16]          ; return F, x > 0
        jmp    .return
    .T: movsd   xmm0, qword [rsp + 8]           ; return T, x <= 0

    .return:
        retn
$endp
}

macro @@ie.bez.fpu
{
$usprocf @@ie.bez

        fld     qword [rsp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        ftst                                    ; compare x to 0
        fstp    st0
        fnjle  .T                               ; jump if x <= 0

    .F: fld     qword [rsp + 16]                ; return F, x > 0
        jmp    .return
    .T: fld     qword [rsp + 8]                 ; return T, x <= 0

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@ie.bez.sse
$else
  @@ie.bez.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; conditional function
; double ie.e ( double x, double y, double T, double F )
; x = rsp
; y = rsp + 8
; T = rsp + 16
; F = rsp + 24
;
; returns: T, x = y
;          F, x <> y

macro @@ie.e.sse
{
$usprocf @@ie.e

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        ucomisd xmm0, xmm1                      ; compare x to y
        jnz    .F                               ; jump if x <> y
        jp     .F                               ; jump if x <> y

    .T: movsd   xmm0, qword [rsp + 16]          ; return T, x = y
        jmp    .return
    .F: movsd   xmm0, qword [rsp + 24]          ; return F, x <> y

    .return:
        retn
$endp
}

macro @@ie.e.fpu
{
$usprocf @@ie.e

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        fcompp                                  ; compare y to x
        fnje   .T                               ; jump if y = x

    .F: fld     qword [rsp + 24]                ; return F, x <> y
        jmp    .return
    .T: fld     qword [rsp + 16]                ; return T, x = y

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@ie.e.sse
$else
  @@ie.e.fpu
$end

; ------------------------------------------------------------------------------

; conditional function
; double ie.ne ( double x, double y, double T, double F )
; x = rsp
; y = rsp + 8
; T = rsp + 16
; F = rsp + 24
;
; returns: T, x <> y
;          F, x = y

macro @@ie.ne.sse
{
$usprocf @@ie.ne

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        ucomisd xmm0, xmm1                      ; compare x to y
        jnz    .T                               ; jump if x <> y
        jp     .T                               ; jump if x <> y

    .F: movsd   xmm0, qword [rsp + 24]          ; return F, x = y
        jmp    .return
    .T: movsd   xmm0, qword [rsp + 16]          ; return T, x <> y

    .return:
        retn
$endp
}

macro @@ie.ne.fpu
{
$usprocf @@ie.ne

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        fcompp                                  ; compare y to x
        fnjne  .T                               ; jump if y <> x

    .F: fld     qword [rsp + 24]                ; return F, x = y
        jmp    .return
    .T: fld     qword [rsp + 16]                ; return T, x <> y

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@ie.ne.sse
$else
  @@ie.ne.fpu
$end

; ------------------------------------------------------------------------------

; conditional function
; double ie.a ( double x, double y, double T, double F )
; x = rsp
; y = rsp + 8
; T = rsp + 16
; F = rsp + 24
;
; returns: T, x > y
;          F, x <= y

macro @@ie.a.sse
{
$usprocf @@ie.a

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        comisd  xmm0, xmm1                      ; compare x to y
        ja     .T                               ; jump if x > y

    .F: movsd   xmm0, qword [rsp + 24]          ; return F, x <= y
        jmp    .return
    .T: movsd   xmm0, qword [rsp + 16]          ; return T, x > y

    .return:
        retn
$endp
}

macro @@ie.a.fpu
{
$usprocf @@ie.a

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        fcompp                                  ; compare y to x
        fnjl   .T                               ; jump if y < x (x > y)

    .F: fld     qword [rsp + 24]                ; return F, x <= y
        jmp    .return
    .T: fld     qword [rsp + 16]                ; return T, x > y

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@ie.a.sse
$else
  @@ie.a.fpu
$end

; ------------------------------------------------------------------------------

; conditional function
; double ie.ae ( double x, double y, double T, double F )
; x = rsp
; y = rsp + 8
; T = rsp + 16
; F = rsp + 24
;
; returns: T, x >= y
;          F, x < y

macro @@ie.ae.sse
{
$usprocf @@ie.ae

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        comisd  xmm0, xmm1                      ; compare x to y
        jae    .T                               ; jump if x >= y

    .F: movsd   xmm0, qword [rsp + 24]          ; return F, x < y
        jmp    .return
    .T: movsd   xmm0, qword [rsp + 16]          ; return T, x >= y

    .return:
        retn
$endp
}

macro @@ie.ae.fpu
{
$usprocf @@ie.ae

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        fcompp                                  ; compare y to x
        fnjle  .T                               ; jump if y <= x (x >= y)

    .F: fld     qword [rsp + 24]                ; return F, x < y
        jmp    .return
    .T: fld     qword [rsp + 16]                ; return T, x >= y

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@ie.ae.sse
$else
  @@ie.ae.fpu
$end

; ------------------------------------------------------------------------------

; conditional function
; double ie.b ( double x, double y, double T, double F )
; x = rsp
; y = rsp + 8
; T = rsp + 16
; F = rsp + 24
;
; returns: T, x < y
;          F, x >= y

macro @@ie.b.sse
{
$usprocf @@ie.b

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        comisd  xmm0, xmm1                      ; compare x to y
        jb     .T                               ; jump if x < y

    .F: movsd   xmm0, qword [rsp + 24]          ; return F, x >= y
        jmp    .return
    .T: movsd   xmm0, qword [rsp + 16]          ; return T, x < y

    .return:
        retn
$endp
}

macro @@ie.b.fpu
{
$usprocf @@ie.b

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        fcompp                                  ; compare y to x
        fnjg   .T                               ; jump if y > x (x < y)

    .F: fld     qword [rsp + 24]                ; return F, x >= y
        jmp    .return
    .T: fld     qword [rsp + 16]                ; return T, x < y

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@ie.b.sse
$else
  @@ie.b.fpu
$end

; ------------------------------------------------------------------------------

; conditional function
; double ie.be ( double x, double y, double T, double F )
; x = rsp
; y = rsp + 8
; T = rsp + 16
; F = rsp + 24
;
; returns: T, x <= y
;          F, x > y

macro @@ie.be.sse
{
$usprocf @@ie.be

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        comisd  xmm0, xmm1                      ; compare x to y
        jbe    .T                               ; jump if x <= y

    .F: movsd   xmm0, qword [rsp + 24]          ; return F, x > y
        jmp    .return
    .T: movsd   xmm0, qword [rsp + 16]          ; return T, x <= y

    .return:
        retn
$endp
}

macro @@ie.be.fpu
{
$usprocf @@ie.be

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        fcompp                                  ; compare y to x
        fnjge  .T                               ; jump if y >= x (x <= y)

    .F: fld     qword [rsp + 24]                ; return F, x > y
        jmp    .return
    .T: fld     qword [rsp + 16]                ; return T, x <= y

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@ie.be.sse
$else
  @@ie.be.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; conditional function
; double ie.bea ( double x, double y, double V1, double V2, double V3 )
; x  = rsp
; y  = rsp + 8
; V1 = rsp + 16
; V2 = rsp + 24
; V3 = rsp + 32
;
; returns: V1, x < y
;          V2, x = y
;          V3, x > y

macro @@ie.bea.sse
{
$usprocf @@ie.bea

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        comisd  xmm0, xmm1                      ; compare x to y
        jb     .V1                              ; jump if x < y
        ja     .V3                              ; jump if x > y

    .V2:movsd   xmm0, qword [rsp + 24]          ; return V2, x = y
        jmp    .return
    .V3:movsd   xmm0, qword [rsp + 32]          ; return V3, x > y
        jmp    .return
    .V1:movsd   xmm0, qword [rsp + 16]          ; return V1, x < y

    .return:
        retn
$endp
}

macro @@ie.bea.fpu
{
$usprocf @@ie.bea

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        fcompp                                  ; compare y to x
        fnstsw  ax
        sahf
        ja     .V1                              ; jump if x < y (y > x)
        jz     .V2                              ; jump if x = y

    .V3:fld     qword [rsp + 32]                ; return V3, x > y
        jmp    .return
    .V2:fld     qword [rsp + 24]                ; return V2, x = y
        jmp    .return
    .V1:fld     qword [rsp + 16]                ; return V1, x < y

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@ie.bea.sse
$else
  @@ie.bea.fpu
$end

; ------------------------------------------------------------------------------

; conditional function
; double ie.aeb ( double x, double y, double V1, double V2, double V3 )
; x  = rsp
; y  = rsp + 8
; V1 = rsp + 16
; V2 = rsp + 24
; V3 = rsp + 32
;
; returns: V1, x > y
;          V2, x = y
;          V3, x < y

macro @@ie.aeb.sse
{
$usprocf @@ie.aeb

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        comisd  xmm0, xmm1                      ; compare x to y
        ja     .V1                              ; jump if x > y
        jb     .V3                              ; jump if x < y

    .V2:movsd   xmm0, qword [rsp + 24]          ; return V2, x = y
        jmp    .return
    .V3:movsd   xmm0, qword [rsp + 32]          ; return V3, x < y
        jmp    .return
    .V1:movsd   xmm0, qword [rsp + 16]          ; return V1, x > y

    .return:
        retn
$endp
}

macro @@ie.aeb.fpu
{
$usprocf @@ie.aeb

        fld     qword [rsp]                     ; st0 = x
        fld     qword [rsp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        fcompp                                  ; compare y to x
        fnstsw  ax
        sahf
        jb     .V1                              ; jump if x > y (y < x)
        jz     .V2                              ; jump if x = y

    .V3:fld     qword [rsp + 32]                ; return V3, x < y
        jmp    .return
    .V2:fld     qword [rsp + 24]                ; return V2, x = y
        jmp    .return
    .V1:fld     qword [rsp + 16]                ; return V1, x > y

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@ie.aeb.sse
$else
  @@ie.aeb.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; conditional function
; double ie.or ( x, Y1, Y2, ..., Yn, T, F )
; variable number of arguments
; r13 -> argument count, min=4
;
; returns: T, (x = Y1) or (x = Y2) or ... or (x = Yn)
;          F, othewise

macro @@ie.or.sse
{
$usprocf @@ie.or

        movsd   xmm0, qword [rsp]               ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        lea     r13, [r13 - 2]                  ; r13 = r13 - 2
        xor     rdx, rdx
    .next.arg:
        inc     rdx
        cmp     rdx, r13
        jne    .compare
        movsd   xmm0, qword [rsp + r13 * 8 + 8] ; load F value
        jmp    .return                          ; no matches
    .compare:
        ucomisd xmm0, qword [rsp + rdx * 8]     ; compare x to Y[i]
        jnz    .next.arg                        ; test next argument if x <> Y[i]
        jp     .next.arg                        ; test next argument if x <> Y[i]
        movsd   xmm0, qword [rsp + r13 * 8]     ; load T value

    .return:
        retn
$endp
}

macro @@ie.or.fpu
{
$usprocf @@ie.or

        fld     qword [rsp]                     ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        lea     r13, [r13 - 2]                  ; r13 = r13 - 2
        xor     rdx, rdx
    .next.arg:
        inc     rdx
        cmp     rdx, r13
        jne    .compare
        fld     qword [rsp + r13 * 8 + 8]       ; load F value
        jmp    .return                          ; no matches
    .compare:
        fcom    qword [rsp + rdx * 8]           ; compare x to Y[i]
        fnjne  .next.arg                        ; test next argument if x <> Y[i]
        fld     qword [rsp + r13 * 8]           ; load T value

    .return:
        fstp    st1                             ; pop x
        retn
$endp
}

$ifdef _SSEX
  @@ie.or.sse
$else
  @@ie.or.fpu
$end

; ------------------------------------------------------------------------------

; conditional function
; double ie.nor ( x, Y1, Y2, ..., Yn, T, F )
; variable number of arguments
; r13 -> argument count, min=4
;
; returns: T, (x <> Y1) and (x <> Y2) and ... and (x <> Yn)
;          F, othewise

macro @@ie.nor.sse
{
$usprocf @@ie.nor

        movsd   xmm0, qword [rsp]               ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        lea     r13, [r13 - 2]                  ; r13 = r13 - 2
        xor     rdx, rdx
    .next.arg:
        inc     rdx
        cmp     rdx, r13
        jne    .compare
        movsd   xmm0, qword [rsp + r13 * 8]     ; load T value
        jmp    .return                          ; complete match
    .compare:
        ucomisd xmm0, qword [rsp + rdx * 8]     ; compare x to Y[i]
        jnz    .next.arg                        ; test next argument if x <> Y[i]
        jp     .next.arg                        ; test next argument if x <> Y[i]
        movsd   xmm0, qword [rsp + r13 * 8 + 8] ; load F value

    .return:
        retn
$endp
}

macro @@ie.nor.fpu
{
$usprocf @@ie.nor

        fld     qword [rsp]                     ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        lea     r13, [r13 - 2]                  ; r13 = r13 - 2
        xor     rdx, rdx
    .next.arg:
        inc     rdx
        cmp     rdx, r13
        jne    .compare
        fld     qword [rsp + r13 * 8]           ; load T value
        jmp    .return                          ; complete match
    .compare:
        fcom    qword [rsp + rdx * 8]           ; compare x to Y[i]
        fnjne  .next.arg                        ; test next argument if x <> Y[i]
        fld     qword [rsp + r13 * 8 + 8]       ; load F value

    .return:
        fstp    st1                             ; pop x
        retn
$endp
}

$ifdef _SSEX
  @@ie.nor.sse
$else
  @@ie.nor.fpu
$end

; ------------------------------------------------------------------------------

; conditional function
; double ie.and ( x, Y1, Y2, ..., Yn, T, F )
; variable number of arguments
; r13 -> argument count, min=4
;
; returns: T, (x = Y1) and (x = Y2) and ... and (x = Yn)
;          F, othewise

macro @@ie.and.sse
{
$usprocf @@ie.and

        movsd   xmm0, qword [rsp]               ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        lea     r13, [r13 - 2]                  ; r13 = r13 - 2
        xor     rdx, rdx
    .next.arg:
        inc     rdx
        cmp     rdx, r13
        jne    .compare
        movsd   xmm0, qword [rsp + r13 * 8]     ; load T value
        jmp    .return                          ; complete match
    .compare:
        ucomisd xmm0, qword [rsp + rdx * 8]     ; compare x to Y[i]
        jnz    .F                               ; return if x <> Y[i]
        jp     .F                               ; return if x <> Y[i]
        jmp    .next.arg                        ; test next argument if x = Y[i]
    .F:
        movsd   xmm0, qword [rsp + r13 * 8 + 8] ; load F value

    .return:
        retn
$endp
}

macro @@ie.and.fpu
{
$usprocf @@ie.and

        fld     qword [rsp]                     ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        lea     r13, [r13 - 2]                  ; r13 = r13 - 2
        xor     rdx, rdx
    .next.arg:
        inc     rdx
        cmp     rdx, r13
        jne    .compare
        fld     qword [rsp + r13 * 8]           ; load T value
        jmp    .return                          ; complete match
    .compare:
        fcom    qword [rsp + rdx * 8]           ; compare x to Y[i]
        fnje   .next.arg                        ; test next argument if x = Y[i]
        fld     qword [rsp + r13 * 8 + 8]       ; load F value

    .return:
        fstp    st1                             ; pop x
        retn
$endp
}

$ifdef _SSEX
  @@ie.and.sse
$else
  @@ie.and.fpu
$end

; ------------------------------------------------------------------------------

; conditional function
; double ie.nand ( x, Y1, Y2, ..., Yn, T, F )
; variable number of arguments
; r13 -> argument count, min=4
;
; returns: T, (x <> Y1) or (x <> Y2) or ... or (x <> Yn)
;          F, othewise

macro @@ie.nand.sse
{
$usprocf @@ie.nand

        movsd   xmm0, qword [rsp]               ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        lea     r13, [r13 - 2]                  ; r13 = r13 - 2
        xor     rdx, rdx
    .next.arg:
        inc     rdx
        cmp     rdx, r13
        jne    .compare
        movsd   xmm0, qword [rsp + r13 * 8 + 8] ; load F value
        jmp    .return                          ; no matches
    .compare:
        ucomisd xmm0, qword [rsp + rdx * 8]     ; compare x to Y[i]
        jnz    .T                               ; return if x <> Y[i]
        jp     .T                               ; return if x <> Y[i]
        jmp    .next.arg                        ; test next argument if x = Y[i]
    .T:
        movsd   xmm0, qword [rsp + r13 * 8]     ; load T value

    .return:
        retn
$endp
}

macro @@ie.nand.fpu
{
$usprocf @@ie.nand

        fld     qword [rsp]                     ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        lea     r13, [r13 - 2]                  ; r13 = r13 - 2
        xor     rdx, rdx
    .next.arg:
        inc     rdx
        cmp     rdx, r13
        jne    .compare
        fld     qword [rsp + r13 * 8 + 8]       ; load F value
        jmp    .return                          ; no matches
    .compare:
        fcom    qword [rsp + rdx * 8]           ; compare x to Y[i]
        fnje   .next.arg                        ; test next argument if x = Y[i]
        fld     qword [rsp + r13 * 8]           ; load T value

    .return:
        fstp    st1                             ; pop x
        retn
$endp
}

$ifdef _SSEX
  @@ie.nand.sse
$else
  @@ie.nand.fpu
$end

; ------------------------------------------------------------------------------
