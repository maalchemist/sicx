
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (complex number functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; complex compile-time value
$usprocf @@ccovalue

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; assign complex compile-time value
; return complex
$usprocf @@crestore

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; assign complex compile-time value
; return void
$usprocf @@creset

        nop
;       retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; copy complex to complex
; return complex number
;
; z1 = a + i•b
; z2 = c + i•d
; ccopy(*a,*b, c,d)
; a := c
; b := d
;
; rcx     = a variable address
; rdx     = b variable address
; rsp + 0 = c
; rsp + 8 = d
;
; return_1 = st1 = a' = c
; return_2 = st0 = b' = d

macro @@ccopy.sse
{
$usprocf @@ccopy

        movsd   xmm0, qword [rsp]               ; xmm0 = c
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = d
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   qword [rcx], xmm0               ; copy c to a
        movsd   qword [rdx], xmm1               ; copy d to b
   .return:
        retn
$endp
}

macro @@ccopy.fpu
{
$usprocf @@ccopy

        fld     qword [rsp]                     ; load c
        fld     qword [rsp + 8]                 ; load d
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = d | st1 = c
        fxch                                    ; st0 = c | st1 = d
        fst     qword [rcx]                     ; copy c to a
        fxch                                    ; st0 = d | st1 = c
        fst     qword [rdx]                     ; copy d to b
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@ccopy.sse
$else
  @@ccopy.fpu
$end

; ------------------------------------------------------------------------------

; copy complex to complex
; return void
;
; z1 = a + i•b
; z2 = c + i•d
; cmove(*a,*b, c,d)
; a := c
; b := d
;
; rcx     = a variable address
; rdx     = b variable address
; rsp + 0 = c
; rsp + 8 = d

macro @@cmove.sse
{
$usprocf @@cmove

        movsd   xmm0, qword [rsp]               ; xmm0 = c
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = d
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   qword [rcx], xmm0               ; copy c to a
        movsd   qword [rdx], xmm1               ; copy d to b
   .return:
        retn
$endp
}

macro @@cmove.fpu
{
$usprocf @@cmove

        fld     qword [rsp]                     ; load c
        fld     qword [rsp + 8]                 ; load d
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = d | st1 = c
        fstp    qword [rdx]                     ; copy d to b
        fstp    qword [rcx]                     ; copy c to a
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cmove.sse
$else
  @@cmove.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; indirect copy complex to complex
; return complex number
;
; z = a + i•b
; cpcopy(p, a,b)
; p.re := a
; p.im := b
;
; rcx     = p = T_complex address
; rsp + 0 = a
; rsp + 8 = b
;
; return_1 = st1 = a
; return_2 = st0 = b

macro @@cpcopy.sse
{
$usprocf @@cpcopy

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        test    rcx, rcx
        jz     .return
   .accept:
        movsd   qword [rcx], xmm0               ; copy a to p.re
        movsd   qword [rcx + 8], xmm1           ; copy b to p.im
   .return:
        retn
$endp
}

macro @@cpcopy.fpu
{
$usprocf @@cpcopy

        fld     qword [rsp]                     ; load a
        fld     qword [rsp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b | st1 = a
        test    rcx, rcx
        jz     .return
   .accept:
        fxch                                    ; st0 = a | st1 = b
        fst     qword [rcx]                     ; copy a to p.re
        fxch                                    ; st0 = b | st1 = a
        fst     qword [rcx + 8]                 ; copy b to p.im
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cpcopy.sse
$else
  @@cpcopy.fpu
$end

; ------------------------------------------------------------------------------

; indirect copy complex to complex
; return void
;
; z = a + i•b
; cpmove(p, a,b)
; p.re := a
; p.im := b
;
; rcx     = p = T_complex address
; rsp + 0 = a
; rsp + 8 = b

macro @@cpmove.sse
{
$usprocf @@cpmove

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        test    rcx, rcx
        jz     .return
   .accept:
        movsd   qword [rcx], xmm0               ; copy a to p.re
        movsd   qword [rcx + 8], xmm1           ; copy b to p.im
   .return:
        retn
$endp
}

macro @@cpmove.fpu
{
$usprocf @@cpmove

        fld     qword [rsp]                     ; load a
        fld     qword [rsp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b | st1 = a
        test    rcx, rcx
        jnz    .accept
   .bypass:
        fstp    st0
        fstp    st0
        jmp    .return
   .accept:
        fstp    qword [rcx + 8]                 ; copy b to p.im
        fstp    qword [rcx]                     ; copy a to p.re
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cpmove.sse
$else
  @@cpmove.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; copy x to complex.re and im
; return complex number
;
; z = a + i•b
; cxcopy(*a,*b, x)
; a := x
; b := x
;
; rcx     = a variable address
; rdx     = b variable address
; rsp + 0 = x
;
; return_1 = st1 = a' = x
; return_2 = st0 = b' = x

macro @@cxcopy.sse
{
$usprocf @@cxcopy

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   xmm1, xmm0                      ; xmm1 = x
        movsd   qword [rcx], xmm0               ; copy x to a
        movsd   qword [rdx], xmm0               ; copy x to b
   .return:
        retn
$endp
}

macro @@cxcopy.fpu
{
$usprocf @@cxcopy

        fld     qword [rsp]                     ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = x
        fld     st0                             ; st0 = x | st1 = x
        fst     qword [rcx]                     ; copy x to a
        fst     qword [rdx]                     ; copy x to b
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cxcopy.sse
$else
  @@cxcopy.fpu
$end

; ------------------------------------------------------------------------------

; copy x to complex.re and im
; return void
;
; z = a + i•b
; cxmove(*a,*b, x)
; a := x
; b := x
;
; rcx     = a variable address
; rdx     = b variable address
; rsp + 0 = x

macro @@cxmove.sse
{
$usprocf @@cxmove

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   qword [rcx], xmm0               ; copy x to a
        movsd   qword [rdx], xmm0               ; copy x to b
   .return:
        retn
$endp
}

macro @@cxmove.fpu
{
$usprocf @@cxmove

        fld     qword [rsp]                     ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = x
        fst     qword [rcx]                     ; copy x to a
        fstp    qword [rdx]                     ; copy x to b
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cxmove.sse
$else
  @@cxmove.fpu
$end

; ------------------------------------------------------------------------------

; copy 0 to complex.re and im
; return complex number
;
; z = a + i•b
; czcopy(*a,*b)
; a := 0
; b := 0
;
; rcx = a variable address
; rdx = b variable address
;
; return_1 = st1 = a' = 0
; return_2 = st0 = b' = 0

macro @@czcopy.sse
{
$usprocf @@czcopy

   .enter:
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        xorpd   xmm1, xmm1                      ; xmm1 = 0
        movsd   qword [rcx], xmm1               ; copy 0 to a
        movsd   qword [rdx], xmm1               ; copy 0 to b
   .return:
        retn
$endp
}

macro @@czcopy.fpu
{
$usprocf @@czcopy

   .enter:
        fldz                                    ; st0 = 0
        fldz                                    ; st0 = 0 | st1 = 0
        fst     qword [rcx]                     ; copy 0 to a
        fst     qword [rdx]                     ; copy 0 to b
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@czcopy.sse
$else
  @@czcopy.fpu
$end

; ------------------------------------------------------------------------------

; copy 0 to complex.re and im
; return void
;
; z = a + i•b
; czmove(*a,*b)
; a := 0
; b := 0
;
; rcx = a variable address
; rdx = b variable address

macro @@czmove.sse
{
$usprocf @@czmove

   .enter:
        xorpd   xmm0, xmm0                      ; xmm0 = 0
;       xorpd   xmm1, xmm1                      ; xmm1 = 0
        movsd   qword [rcx], xmm0               ; copy 0 to a
        movsd   qword [rdx], xmm0               ; copy 0 to b
   .return:
        retn
$endp
}

macro @@czmove.fpu
{
$usprocf @@czmove

   .enter:
        fldz                                    ; st0 = 0
        fst     qword [rcx]                     ; copy 0 to a
        fstp    qword [rdx]                     ; copy 0 to b
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@czmove.sse
$else
  @@czmove.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; copy complex.re to complex.re
; return complex number
;
; z1 = a + i•b
; z2 = c + i•d
; crrcopy(*a,*b, c,d)
; a := c
;
; rcx     = a variable address
; rdx     = b variable address
; rsp + 0 = c
; rsp + 8 = d
;
; return_1 = st1 = a' = c
; return_2 = st0 = b' = b

macro @@crrcopy.sse
{
$usprocf @@crrcopy

        movsd   xmm0, qword [rsp]               ; xmm0 = c
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = d
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   qword [rcx], xmm0               ; copy c to a
        movsd   xmm1, qword [rdx]               ; xmm1 = b
   .return:
        retn
$endp
}

macro @@crrcopy.fpu
{
$usprocf @@crrcopy

        fld     qword [rsp]                     ; load c
        fld     qword [rsp + 8]                 ; load d
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = d | st1 = c
        fstp    st0                             ; st0 = c
        fst     qword [rcx]                     ; copy c to a
        fld     qword [rdx]                     ; st0 = b | st1 = c
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@crrcopy.sse
$else
  @@crrcopy.fpu
$end

; ------------------------------------------------------------------------------

; copy complex.re to complex.re
; return void
;
; z1 = a + i•b
; z2 = c + i•d
; crrmove(*a,*b, c,d)
; a := c
;
; rcx     = a variable address
; rdx     = b variable address
; rsp + 0 = c
; rsp + 8 = d

macro @@crrmove.sse
{
$usprocf @@crrmove

        movsd   xmm0, qword [rsp]               ; xmm0 = c
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = d
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   qword [rcx], xmm0               ; copy c to a
   .return:
        retn
$endp
}

macro @@crrmove.fpu
{
$usprocf @@crrmove

        fld     qword [rsp]                     ; load c
        fld     qword [rsp + 8]                 ; load d
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = d | st1 = c
        fstp    st0                             ; st0 = c
        fstp    qword [rcx]                     ; copy c to a
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@crrmove.sse
$else
  @@crrmove.fpu
$end

; ------------------------------------------------------------------------------

; copy x to complex.re
; return complex number
;
; z = a + i•b
; cxrcopy(*a,*b, x)
; a := x
;
; rcx     = a variable address
; rdx     = b variable address
; rsp + 0 = x
;
; return_1 = st1 = a' = x
; return_2 = st0 = b' = b

macro @@cxrcopy.sse
{
$usprocf @@cxrcopy

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   qword [rcx], xmm0               ; copy x to a
        movsd   xmm1, qword [rdx]               ; xmm1 = b
   .return:
        retn
$endp
}

macro @@cxrcopy.fpu
{
$usprocf @@cxrcopy

        fld     qword [rsp]                     ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = x
        fst     qword [rcx]                     ; copy x to a
        fld     qword [rdx]                     ; st0 = b | st1 = x
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cxrcopy.sse
$else
  @@cxrcopy.fpu
$end

; ------------------------------------------------------------------------------

; copy x to complex.re
; return void
;
; z = a + i•b
; cxrmove(*a,*b, x)
; a := x
;
; rcx     = a variable address
; rdx     = b variable address
; rsp + 0 = x

macro @@cxrmove.sse
{
$usprocf @@cxrmove

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   qword [rcx], xmm0               ; copy x to a
   .return:
        retn
$endp
}

macro @@cxrmove.fpu
{
$usprocf @@cxrmove

        fld     qword [rsp]                     ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = x
        fstp    qword [rcx]                     ; copy x to a
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cxrmove.sse
$else
  @@cxrmove.fpu
$end

; ------------------------------------------------------------------------------

; copy 0 to complex.re
; return complex number
;
; z = a + i•b
; czrcopy(*a,*b)
; a := 0
;
; rcx = a variable address
; rdx = b variable address
;
; return_1 = st1 = a' = 0
; return_2 = st0 = b' = b

macro @@czrcopy.sse
{
$usprocf @@czrcopy

        xorpd   xmm0, xmm0                      ; xmm0 = 0
        movsd   qword [rcx], xmm0               ; copy 0 to a
        movsd   xmm1, qword [rdx]               ; xmm1 = b
   .return:
        retn
$endp
}

macro @@czrcopy.fpu
{
$usprocf @@czrcopy

        fldz
        fst     qword [rcx]                     ; copy 0 to a
        fld     qword [rdx]                     ; st0 = b | st1 = 0
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@czrcopy.sse
$else
  @@czrcopy.fpu
$end

; ------------------------------------------------------------------------------

; copy 0 to complex.re
; return void
;
; z = a + i•b
; czrmove(*a,*b)
; a := 0
;
; rcx = a variable address
; rdx = b variable address

macro @@czrmove.sse
{
$usprocf @@czrmove

        xorpd   xmm0, xmm0                      ; xmm0 = 0
        movsd   qword [rcx], xmm0               ; copy 0 to a
   .return:
        retn
$endp
}

macro @@czrmove.fpu
{
$usprocf @@czrmove

        fldz
        fstp    qword [rcx]                     ; copy 0 to a
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@czrmove.sse
$else
  @@czrmove.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; copy complex.im to complex.im
; return complex number
;
; z1 = a + i•b
; z2 = c + i•d
; ciicopy(*a,*b, c,d)
; b := d
;
; rcx     = a variable address
; rdx     = b variable address
; rsp + 0 = c
; rsp + 8 = d
;
; return_1 = st1 = a' = a
; return_2 = st0 = b' = d

macro @@ciicopy.sse
{
$usprocf @@ciicopy

        movsd   xmm0, qword [rsp]               ; xmm0 = c
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = d
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   xmm0, qword [rcx]               ; xmm0 = a
        movsd   qword [rdx], xmm1               ; copy d to b
   .return:
        retn
$endp
}

macro @@ciicopy.fpu
{
$usprocf @@ciicopy

        fld     qword [rsp]                     ; load c
        fld     qword [rsp + 8]                 ; load d
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = d | st1 = c
        fst     qword [rdx]                     ; copy d to b
        fstp    st1                             ; st0 = d
        fld     qword [rcx]                     ; st0 = a | st1 = d
        fxch                                    ; st0 = d | st1 = a
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@ciicopy.sse
$else
  @@ciicopy.fpu
$end

; ------------------------------------------------------------------------------

; copy complex.im to complex.im
; return void
;
; z1 = a + i•b
; z2 = c + i•d
; ciimove(*a,*b, c,d)
; b := d
;
; rcx     = a variable address
; rdx     = b variable address
; rsp + 0 = c
; rsp + 8 = d

macro @@ciimove.sse
{
$usprocf @@ciimove

        movsd   xmm0, qword [rsp]               ; xmm0 = c
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = d
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   qword [rdx], xmm1               ; copy d to b
   .return:
        retn
$endp
}

macro @@ciimove.fpu
{
$usprocf @@ciimove

        fld     qword [rsp]                     ; load c
        fld     qword [rsp + 8]                 ; load d
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = d | st1 = c
        fstp    st1
        fstp    qword [rdx]                     ; copy d to b
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@ciimove.sse
$else
  @@ciimove.fpu
$end

; ------------------------------------------------------------------------------

; copy x to complex.im
; return complex number
;
; z = a + i•b
; cxicopy(*a,*b, x)
; b := x
;
; rcx     = a variable address
; rdx     = b variable address
; rsp + 0 = x
;
; return_1 = st1 = a' = a
; return_2 = st0 = b' = x

macro @@cxicopy.sse
{
$usprocf @@cxicopy

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   qword [rdx], xmm0               ; copy x to b
        movsd   xmm1, xmm0                      ; xmm1 = x
        movsd   xmm0, qword [rcx]               ; xmm0 = a
   .return:
        retn
$endp
}

macro @@cxicopy.fpu
{
$usprocf @@cxicopy

        fld     qword [rsp]                     ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = x
        fst     qword [rdx]                     ; copy x to b
        fld     qword [rcx]                     ; st0 = a | st1 = x
        fxch                                    ; st0 = x | st1 = a
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cxicopy.sse
$else
  @@cxicopy.fpu
$end

; ------------------------------------------------------------------------------

; copy x to complex.im
; return void
;
; z = a + i•b
; cximove(*a,*b, x)
; b := x
;
; rcx     = a variable address
; rdx     = b variable address
; rsp + 0 = x

macro @@cximove.sse
{
$usprocf @@cximove

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   qword [rdx], xmm0               ; copy x to b
   .return:
        retn
$endp
}

macro @@cximove.fpu
{
$usprocf @@cximove

        fld     qword [rsp]                     ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = x
        fstp    qword [rdx]                     ; copy x to b
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cximove.sse
$else
  @@cximove.fpu
$end

; ------------------------------------------------------------------------------

; copy 0 to complex.im
; return complex number
;
; z = a + i•b
; czicopy(*a,*b)
; b := 0
;
; rcx = a variable address
; rdx = b variable address
;
; return_1 = st1 = a' = a
; return_2 = st0 = b' = 0

macro @@czicopy.sse
{
$usprocf @@czicopy

        movsd   xmm0, qword [rcx]               ; xmm0 = a
        xorpd   xmm1, xmm1                      ; xmm1 = 0
        movsd   qword [rdx], xmm1               ; copy 0 to b
   .return:
        retn
$endp
}

macro @@czicopy.fpu
{
$usprocf @@czicopy

        fld     qword [rcx]                     ; st0 = a
        fldz                                    ; st0 = 0 | st1 = a
        fst     qword [rdx]                     ; copy 0 to b
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@czicopy.sse
$else
  @@czicopy.fpu
$end

; ------------------------------------------------------------------------------

; copy 0 to complex.im
; return void
;
; z = a + i•b
; czimove(*a,*b)
; b := 0
;
; rcx = a variable address
; rdx = b variable address

macro @@czimove.sse
{
$usprocf @@czimove

        xorpd   xmm0, xmm0                      ; xmm0 = 0
        movsd   qword [rdx], xmm0               ; copy 0 to b
   .return:
        retn
$endp
}

macro @@czimove.fpu
{
$usprocf @@czimove

        fldz
        fstp    qword [rdx]                     ; copy 0 to b
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@czimove.sse
$else
  @@czimove.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; complex swap
; return complex
;
; z1 = a + i•b
; z2 = c + i•d
; cswap(*a,*b, *c,*d)
; a :=: c
; b :=: d
;
; rcx = a variable address
; rdx = b variable address
; rax = c variable address
; rbx = d variable address
;
; return_1 = st1 = c
; return_2 = st0 = d

macro @@cswap.sse
{
$usprocf @@cswap

        movsd   xmm0, qword [rax]               ; xmm0 = c
        movsd   xmm1, qword [rbx]               ; xmm1 = d
        movsd   xmm2, qword [rcx]               ; xmm2 = a
        movsd   xmm3, qword [rdx]               ; xmm3 = b
   .enter:                                      ; st0 = b | st1 = a | st2 = c | st3 = d
        movsd   qword [rax], xmm2               ; copy a to c
        movsd   qword [rbx], xmm3               ; copy b to d
        movsd   qword [rcx], xmm0               ; copy c to a
        movsd   qword [rdx], xmm1               ; copy d to b
   .return:
        retn
$endp
}

macro @@cswap.fpu
{
$usprocf @@cswap

        fld     qword [rbx]                     ; load d
        fld     qword [rax]                     ; load c
        fld     qword [rcx]                     ; load a
        fld     qword [rdx]                     ; load b
   .enter:                                      ; st0 = b | st1 = a | st2 = c | st3 = d
        fstp    qword [rbx]                     ; copy b to d
                                                ; st0 = a | st1 = c | st2 = d
        fstp    qword [rax]                     ; copy a to c
                                                ; st0 = c | st1 = d
        fst     qword [rcx]                     ; copy c to a
        fxch                                    ; st0 = d | st1 = c
        fst     qword [rdx]                     ; copy d to b
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cswap.sse
$else
  @@cswap.fpu
$end

; ------------------------------------------------------------------------------

; complex swop
; return void
;
; z1 = a + i•b
; z2 = c + i•d
; cswop(*a,*b, *c,*d)
; a :=: c
; b :=: d
;
; rcx = a variable address
; rdx = b variable address
; rax = c variable address
; rbx = d variable address

macro @@cswop.sse
{
$usprocf @@cswop

        movsd   xmm0, qword [rax]               ; xmm0 = c
        movsd   xmm1, qword [rbx]               ; xmm1 = d
        movsd   xmm2, qword [rcx]               ; xmm2 = a
        movsd   xmm3, qword [rdx]               ; xmm3 = b
   .enter:                                      ; st0 = b | st1 = a | st2 = c | st3 = d
        movsd   qword [rax], xmm2               ; copy a to c
        movsd   qword [rbx], xmm3               ; copy b to d
        movsd   qword [rcx], xmm0               ; copy c to a
        movsd   qword [rdx], xmm1               ; copy d to b
   .return:
        retn
$endp
}

macro @@cswop.fpu
{
$usprocf @@cswop

        fld     qword [rbx]                     ; load d
        fld     qword [rax]                     ; load c
        fld     qword [rcx]                     ; load a
        fld     qword [rdx]                     ; load b
   .enter:                                      ; st0 = b | st1 = a | st2 = c | st3 = d
        fstp    qword [rbx]                     ; copy b to d
                                                ; st0 = a | st1 = c | st2 = d
        fstp    qword [rax]                     ; copy a to c
                                                ; st0 = c | st1 = d
        fstp    qword [rcx]                     ; copy c to a
                                                ; st0 = d
        fstp    qword [rdx]                     ; copy d to b
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cswop.sse
$else
  @@cswop.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; real part of complex z
; z = a + i•b
; creal(a,b) = a
;
; rsp + 0 = a
; rsp + 8 = b

macro @@creal.sse
{
$usprocf @@creal

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .return:
        retn
$endp
}

macro @@creal.fpu
{
$usprocf @@creal

        fld     qword [rsp]                     ; load a
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@creal.sse
$else
  @@creal.fpu
$end

; ------------------------------------------------------------------------------

; imaginary part of complex z
; z = a + i•b
; cimag(a,b) = b
;
; rsp + 0 = a
; rsp + 8 = b

macro @@cimag.sse
{
$usprocf @@cimag

        movsd   xmm0, qword [rsp + 8]           ; xmm0 = b
   .return:
        retn
$endp
}

macro @@cimag.fpu
{
$usprocf @@cimag

        fld     qword [rsp + 8]                 ; load b
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cimag.sse
$else
  @@cimag.fpu
$end

; ------------------------------------------------------------------------------

; real part of complex z and zero
; z = a + i•b
; creze(a,b) = (a,0)
;
; rsp + 0 = a
; rsp + 8 = b
;
; return_1 = st1 = a
; return_2 = st0 = 0

macro @@creze.sse
{
$usprocf @@creze

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
        xorpd   xmm1, xmm1                      ; xmm1 = 0
   .return:
        retn
$endp
}

macro @@creze.fpu
{
$usprocf @@creze

        fld     qword [rsp]                     ; load a
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
        fldz
   .return:                                     ; st0 = 0 | st1 = a
        retn
$endp
}

$ifdef _SSEX
  @@creze.sse
$else
  @@creze.fpu
$end

; ------------------------------------------------------------------------------

; zero and imaginary part of complex z
; z = a + i•b
; czeim(a,b) = (0,b)
;
; rsp + 0 = a
; rsp + 8 = b
;
; return_1 = st1 = 0
; return_2 = st0 = b

macro @@czeim.sse
{
$usprocf @@czeim

        xorpd   xmm0, xmm0                      ; xmm0 = 0
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
   .return:
        retn
$endp
}

macro @@czeim.fpu
{
$usprocf @@czeim

        fldz
        fld     qword [rsp + 8]                 ; load b
   .return:                                     ; st0 = b | st1 = 0
        retn
$endp
}

$ifdef _SSEX
  @@czeim.sse
$else
  @@czeim.fpu
$end

; ------------------------------------------------------------------------------

; zero
; z = a + i•b
; czero(a,b) = (0,0)
;
; rsp + 0 = a
; rsp + 8 = b
;
; return_1 = st1 = 0
; return_2 = st0 = 0

macro @@czero.sse
{
$usprocf @@czero

   .enter:
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        xorpd   xmm1, xmm1                      ; xmm1 = 0
   .return:
        retn
$endp
}

macro @@czero.fpu
{
$usprocf @@czero

   .enter:
        fldz
        fldz
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@czero.sse
$else
  @@czero.fpu
$end

; ------------------------------------------------------------------------------

; void
; z = a + i•b
; cvoid(a,b) = void
;
; rsp + 0 = a
; rsp + 8 = b

$usprocf @@cvoid

        nop
;       retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; re_1 + i•re_2
; z1 = a + i•b
; z2 = c + i•d
; crere(a,b,c,d) = a + i•c
;
; rsp + 0  = a
; rsp + 8  = b
; rsp + 16 = c
; rsp + 24 = d
;
; return_1 = st1 = a
; return_2 = st0 = c

macro @@crere.sse
{
$usprocf @@crere

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
        movsd   xmm1, qword [rsp + 16]          ; xmm1 = c
   .enter:
   .return:
        retn
$endp
}

macro @@crere.fpu
{
$usprocf @@crere

        fld     qword [rsp]                     ; load a
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
        fld     qword [rsp + 16]                ; load c
   .enter:
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@crere.sse
$else
  @@crere.fpu
$end

; ------------------------------------------------------------------------------

; re_1 + i•im_2
; z1 = a + i•b
; z2 = c + i•d
; creim(a,b,c,d) = a + i•d
;
; rsp + 0  = a
; rsp + 8  = b
; rsp + 16 = c
; rsp + 24 = d
;
; return_1 = st1 = a
; return_2 = st0 = d

macro @@creim.sse
{
$usprocf @@creim

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
        movsd   xmm1, qword [rsp + 24]          ; xmm1 = d
   .enter:
   .return:
        retn
$endp
}

macro @@creim.fpu
{
$usprocf @@creim

        fld     qword [rsp]                     ; load a
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
        fld     qword [rsp + 24]                ; load d
   .enter:
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@creim.sse
$else
  @@creim.fpu
$end

; ------------------------------------------------------------------------------

; im_1 + i•re_2
; z1 = a + i•b
; z2 = c + i•d
; cimre(a,b,c,d) = b + i•c
;
; rsp + 0  = a
; rsp + 8  = b
; rsp + 16 = c
; rsp + 24 = d
;
; return_1 = st1 = b
; return_2 = st0 = c

macro @@cimre.sse
{
$usprocf @@cimre

        movsd   xmm0, qword [rsp + 8]           ; xmm0 = b
        movsd   xmm1, qword [rsp + 16]          ; xmm1 = c
   .enter:
   .return:
        retn
$endp
}

macro @@cimre.fpu
{
$usprocf @@cimre

        fld     qword [rsp + 8]                 ; load b
        fld     qword [rsp + 16]                ; load c
   .enter:
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cimre.sse
$else
  @@cimre.fpu
$end

; ------------------------------------------------------------------------------

; im_1 + i•im_2
; z1 = a + i•b
; z2 = c + i•d
; cimim(a,b,c,d) = b + i•d
;
; rsp + 0  = a
; rsp + 8  = b
; rsp + 16 = c
; rsp + 24 = d
;
; return_1 = st1 = b
; return_2 = st0 = d

macro @@cimim.sse
{
$usprocf @@cimim

        movsd   xmm0, qword [rsp + 8]           ; xmm0 = b
        movsd   xmm1, qword [rsp + 24]          ; xmm1 = d
   .enter:
   .return:
        retn
$endp
}

macro @@cimim.fpu
{
$usprocf @@cimim

        fld     qword [rsp + 8]                 ; load b
        fld     qword [rsp + 24]                ; load d
   .enter:
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cimim.sse
$else
  @@cimim.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; complex polar from plane
; z = a + i•b = r*exp(i•t)
; cpolar(a,b) = (r,t)
; r = (a^2 + b^2)^(1/2)
; t = atan(b/a) (-pi < t <= pi)
;
; rsp + 0 = a
; rsp + 8 = b
;
; return_1 = st1 = r = (a^2 + b^2)^(1/2)
; return_2 = st0 = t = atan(b/a)

macro @@cpolar.sse
{
$usprocf @@cpolar

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   xmm2, xmm0                      ; xmm2 = a
        movsd   xmm3, xmm1                      ; xmm3 = b
        mov     rdx, @@fatan2r.enter
        call    rdx                             ; xmm0 = t
        @@.xch  xmm0, xmm2
        movapd  xmm1, xmm3
        mov     rdx, @@cabs.enter
        call    rdx                             ; xmm0 = r
        movapd  xmm1, xmm2
   .return:
        retn
$endp

macro @@.cpolar.fpu
\{
$usprocf @@cpolar

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   xmm2, xmm0                      ; xmm2 = a
        movsd   xmm3, xmm1                      ; xmm3 = b
        mov     rdx, @@cabs.enter
        call    rdx                             ; xmm0 = r
        ;
        @@.fld.xmm3                             ; st0 = b
        @@.fld.xmm2                             ; st0 = a | st1 = b
        fpatan                                  ; st0 = t
        @@.fstp.xmm1
   .return:
        retn
$endp
\}

$asprocf @@cpolar.enter.fpu
                                                ; st0 = b   | st1 = a
        fld     st1                             ; st0 = a   | st1 = b   | st2 = a
        fld     st1                             ; st0 = b   | st1 = a   | st2 = b | st3 = a
        mov     rdx, @@cabs.enter.fpu
        call    rdx                             ; st0 = r   | st1 = b   | st2 = a
        fxch    st2                             ; st0 = a   | st1 = b   | st2 = r
        fpatan                                  ; st0 = t   | st1 = r
   .return:
        retn
$endp
}

macro @@cpolar.fpu
{
$usprocf @@cpolar

        fld     qword [rsp]                     ; load a
        fld     qword [rsp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b   | st1 = a
        fld     st1                             ; st0 = a   | st1 = b   | st2 = a
        fld     st1                             ; st0 = b   | st1 = a   | st2 = b | st3 = a
        mov     rdx, @@cabs.enter
        call    rdx                             ; st0 = r   | st1 = b   | st2 = a
        fxch    st2                             ; st0 = a   | st1 = b   | st2 = r
        fpatan                                  ; st0 = t   | st1 = r
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cpolar.sse
$else
  @@cpolar.fpu
$end

; ------------------------------------------------------------------------------

; complex plane from polar
; z = r*exp(i•t) = a + i•b
; cplane(r,t) = (a,b)
; a = r*cos(t)
; b = r*sin(t)
;
; rsp + 0 = r
; rsp + 8 = t
;
; return_1 = st1 = a = r*cos(t)
; return_2 = st0 = b = r*sin(t)

macro @@cplane.sse
{
$usprocf @@cplane

        movsd   xmm0, qword [rsp]               ; xmm0 = r
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = t
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movapd  xmm2, xmm0
        movapd  xmm0, xmm1
        mov     rdx, @@fcossin.enter
        call    rdx
        mulsd   xmm0, xmm2                      ; xmm0 = r * cos(t)
        mulsd   xmm1, xmm2                      ; xmm1 = r * sin(t)
   .return:
        retn
$endp

macro @@.cplane.fpu
\{
$usprocf @@cplane

        movsd   xmm0, qword [rsp]               ; xmm0 = r
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = t
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm1
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos(t) | st1 = sin(t)
        @@.fstp.xmm2                            ; xmm2 = cos(t)
        @@.fstp.xmm1                            ; xmm1 = sin(t)
        ;
        mulsd   xmm1, xmm0                      ; xmm1 = r * sin(t)
        mulsd   xmm0, xmm2                      ; xmm0 = r * cos(t)
   .return:
        retn
$endp
\}
}

macro @@cplane.fpu
{
$usprocf @@cplane

        fld     qword [rsp]                     ; load r
        fld     qword [rsp + 8]                 ; load t
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = t      | st1 = r
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos(t) | st1 = sin(t) | st2 = r
        fxch    st2                             ; st0 = r      | st1 = sin(t) | st2 = cos(t)
        fmul    st2, st0                        ; st0 = r      | st1 = sin(t) | st2 = a
        fmulp                                   ; st0 = b      | st1 = a
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cplane.sse
$else
  @@cplane.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; norm value of z
; z = a + i•b
; cnorm(a,b) = a^2 + b^2
;
; rsp + 0 = a
; rsp + 8 = b

macro @@cnorm.sse
{
$usprocf @@cnorm

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mulsd   xmm0, xmm0
        mulsd   xmm1, xmm1
        addsd   xmm0, xmm1                      ; xmm0 = a^2+b^2
   .return:
        retn
$endp
}

macro @@cnorm.fpu
{
$usprocf @@cnorm

        fld     qword [rsp]                     ; load a
        fld     qword [rsp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b | st1 = a
        fmul    st0, st0
        fxch
        fmul    st0, st0
        faddp
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cnorm.sse
$else
  @@cnorm.fpu
$end

; ------------------------------------------------------------------------------

; norm values
; z1 = a + i•b
; z2 = c + i•d
;
; rsp + 0  = a
; rsp + 8  = b
; rsp + 16 = c
; rsp + 24 = d
;
; return_1 = st1 = norm_1
; return_2 = st0 = norm_2
;
; norm_1 = a^2 + b^2
; norm_2 = c^2 + d^2

macro @@cnorms.sse
{
$usprocf @@cnorms

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
        mulsd   xmm0, xmm0
        mulsd   xmm1, xmm1
        addsd   xmm0, xmm1                      ; xmm0 = norm_1 = a^2+b^2
        movsd   xmm1, qword [rsp + 16]          ; xmm1 = c
        movsd   xmm2, qword [rsp + 24]          ; xmm2 = d
        mulsd   xmm1, xmm1
        mulsd   xmm2, xmm2
        addsd   xmm1, xmm2                      ; xmm1 = norm_2 = c^2+d^2
   .return:
        retn
$endp
}

macro @@cnorms.fpu
{
$usprocf @@cnorms

        fld     qword [rsp]                     ; load a
        fld     qword [rsp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
        fmul    st0, st0
        fxch
        fmul    st0, st0
        faddp                                   ; st0 = norm_1
        fld     qword [rsp + 16]                ; load c
        fmul    st0, st0
        fld     qword [rsp + 24]                ; load d
        fmul    st0, st0
        faddp                                   ; st0 = norm_2 | st1 = norm_1
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cnorms.sse
$else
  @@cnorms.fpu
$end

; ------------------------------------------------------------------------------

; absolute value of z
; z = a + i•b
; cabs(a,b) = (a^2 + b^2)^(1/2)
;
; rsp + 0 = a
; rsp + 8 = b
;
; cabs = |b|*(1+(a/b)^2)^(1/2), |a|<|b| (for greater precision)
; |A|<|B| (A=min(a,b), B=max(a,b))

macro @@cabs.sse
{
$usprocf @@cabs

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.abss xmm0, xmm1                      ; xmm0 = |a|
                                                ; xmm1 = |b|
        comisd  xmm0, xmm1                      ; compare |a| to |b|
        jbe    .1                               ; jump if |a| <= |b|
        @@.xch  xmm0, xmm1
   .1:                                          ; xmm0 = |A|
                                                ; xmm1 = |B|
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare |A| to 0
        jnz    .2
        jp     .2
   .xz:                                         ; |A|=0
        movsd   xmm0, xmm1                      ; xmm0 = |B|
        jmp    .return
   .2:                                          ; |A|<>0
        divsd   xmm0, xmm1                      ; xmm0 = |A|/|B|
        mulsd   xmm0, xmm0                      ; xmm0 = sqr(|A|/|B|)
        xaddsd  xmm0, ??.1.0                    ; xmm0 = 1+sqr(|A|/|B|)
        sqrtsd  xmm0, xmm0                      ; xmm0 = sqrt(1+sqr(|A|/|B|))
        mulsd   xmm0, xmm1                      ; xmm0 = |B|*sqrt(1+sqr(|A|/|B|))
   .return:
        retn
$endp

$asprocf @@cabs.enter.fpu                       ; -------------------------------------------------
                                                ; ST(0)                    | ST(1)        | ST(2) |
                                                ; -------------------------------------------------
                                                ; a                        | ?            | ?     |
                                                ; b                        | a            | ?     |
        push    rax                             ;                          |              |       |
        fabs                                    ; |b|                      | a            | ?     |
        fxch                                    ; a                        | |b|          | ?     |
        fabs                                    ; |a|                      | |b|          | ?     |
                                                ; -------------------------------------------------
        fcom                                    ; compare |a| to |b|
        fnjle  .1                               ; jump if |a| <= |b|
                                                ; -------------------------------------------------
        fxch    st1                             ; |A|                      | |B|          | ?     |
   .1:  fldz                                    ; 0                        | |A|          | |B|   |
                                                ; -------------------------------------------------
        fcomp                                   ; compare 0 to |A|
                                                ; -------------------------------------------------
                                                ; |A|                      | |B|          | ?     |
                                                ; -------------------------------------------------
        fnjne  .2                               ; jump if 0 <> |A|
                                                ; -------------------------------------------------
        fstp    st0                             ; |B|                      | ?            | ?     |
        jmp    .return                          ;                          |              |       |
                                                ;                          |              |       |
   .2:  fdiv    st0, st1                        ; |A|/|B|                  | |B|          | ?     |
        fmul    st0, st0                        ; sqr(|A|/|B|)             | |B|          | ?     |
        fld1                                    ; 1                        | sqr(|A|/|B|) | |B|   |
        faddp                                   ; 1+sqr(|A|/|B|)           | |B|          | ?     |
        fsqrt                                   ; sqrt(1+sqr(|A|/|B|))     | |B|          | ?     |
        fmulp                                   ; |B|*sqrt(1+sqr(|A|/|B|)) | ?            | ?     |
                                                ; -------------------------------------------------
   .return:
        pop     rax
        retn
$endp
}

macro @@cabs.fpu
{
$usprocf @@cabs                                 ; -------------------------------------------------
                                                ; ST(0)                    | ST(1)        | ST(2) |
                                                ; -------------------------------------------------
        fld     qword [rsp]                     ; a                        | ?            | ?     |
        fld     qword [rsp + 8]                 ; b                        | a            | ?     |
   .enter:                                      ;                          |              |       |
        push    rax                             ;                          |              |       |
        fabs                                    ; |b|                      | a            | ?     |
        fxch                                    ; a                        | |b|          | ?     |
        fabs                                    ; |a|                      | |b|          | ?     |
                                                ; -------------------------------------------------
        fcom                                    ; compare |a| to |b|
        fnjle  .1                               ; jump if |a| <= |b|
                                                ; -------------------------------------------------
        fxch    st1                             ; |A|                      | |B|          | ?     |
   .1:  fldz                                    ; 0                        | |A|          | |B|   |
                                                ; -------------------------------------------------
        fcomp                                   ; compare 0 to |A|
                                                ; -------------------------------------------------
                                                ; |A|                      | |B|          | ?     |
                                                ; -------------------------------------------------
        fnjne  .2                               ; jump if 0 <> |A|
                                                ; -------------------------------------------------
        fstp    st0                             ; |B|                      | ?            | ?     |
        jmp    .return                          ;                          |              |       |
                                                ;                          |              |       |
   .2:  fdiv    st0, st1                        ; |A|/|B|                  | |B|          | ?     |
        fmul    st0, st0                        ; sqr(|A|/|B|)             | |B|          | ?     |
        fld1                                    ; 1                        | sqr(|A|/|B|) | |B|   |
        faddp                                   ; 1+sqr(|A|/|B|)           | |B|          | ?     |
        fsqrt                                   ; sqrt(1+sqr(|A|/|B|))     | |B|          | ?     |
        fmulp                                   ; |B|*sqrt(1+sqr(|A|/|B|)) | ?            | ?     |
                                                ; -------------------------------------------------
   .return:
        pop     rax
        retn
$endp
}

$ifdef _SSEX
  @@cabs.sse
$else
  @@cabs.fpu
$end

; ------------------------------------------------------------------------------

; absolute values
; z1 = a + i•b
; z2 = c + i•d
;
; rsp + 0  = a
; rsp + 8  = b
; rsp + 16 = c
; rsp + 24 = d
;
; return_1 = st1 = abs_1
; return_2 = st0 = abs_2
;
; abs_1 = (a^2 + b^2)^(1/2)
; abs_2 = (c^2 + d^2)^(1/2)

macro @@cabss.sse
{
$usprocf @@cabss

        movsd   xmm0, qword [rsp + 24]          ; xmm0 = d
        movsd   xmm1, qword [rsp + 16]          ; xmm1 = c
        mov     rdx, @@cabs.enter
        call    rdx                             ; xmm0 = abs_2
        movsd   xmm2, xmm0                      ; xmm2 = abs_2
        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        mov     rdx, @@cabs.enter
        call    rdx                             ; xmm0 = abs_1
        movsd   xmm1, xmm2                      ; xmm1 = abs_2
   .return:
        retn
$endp
}

macro @@cabss.fpu
{
$usprocf @@cabss

        fld     qword [rsp]                     ; load a
        fld     qword [rsp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
        mov     rdx, @@cabs.enter
        call    rdx                             ; st0 = abs_1
        fld     qword [rsp + 16]                ; load c
        fld     qword [rsp + 24]                ; load d
        mov     rdx, @@cabs.enter
        call    rdx                             ; st0 = abs_2 | st1 = abs_1
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cabss.sse
$else
  @@cabss.fpu
$end

; ------------------------------------------------------------------------------

; argument of z
; also called phase angle
; z = a + i•b
; carg(a,b) = atan(b/a)
; -pi < carg(z) <= pi
;
; rsp + 0 = a
; rsp + 8 = b

macro @@carg.sse
{
$usprocf @@carg

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     rdx, @@fatan2r.enter
        call    rdx
   .return:
        retn
$endp

macro @@.carg.fpu
\{
$usprocf @@carg

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm1                             ; st0 = b
        @@.fld.xmm0                             ; st0 = a | st1 = b
        fpatan
        @@.fstp.xmm0
   .return:
        retn
$endp
\}
}

macro @@carg.fpu
{
$usprocf @@carg

        fld     qword [rsp]                     ; load a
        fld     qword [rsp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b | st1 = a
        fxch                                    ; st0 = a | st1 = b
        fpatan
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@carg.sse
$else
  @@carg.fpu
$end

; ------------------------------------------------------------------------------

; arguments
; z1 = a + i•b
; z2 = c + i•d
;
; rsp + 0  = a
; rsp + 8  = b
; rsp + 16 = c
; rsp + 24 = d
;
; return_1 = st1 = arg_1
; return_2 = st0 = arg_2
;
; arg_1 = atan(b/a)
; arg_2 = atan(d/c)
; -pi < arg_i <= pi

macro @@cargs.sse
{
$usprocf @@cargs

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = c
        movsd   xmm3, qword [rsp + 24]          ; xmm3 = d
   .enter:
        @@.xch  xmm0, xmm2
        @@.xch  xmm1, xmm3
        mov     rdx, @@fatan2r.enter
        call    rdx
        @@.xch  xmm0, xmm2                      ; xmm2 = arg_2
        @@.xch  xmm1, xmm3
        mov     rdx, @@fatan2r.enter
        call    rdx                             ; xmm0 = arg_1
        movapd  xmm1, xmm2                      ; xmm1 = arg_2
   .return:
        retn
$endp

macro @@.cargs.fpu
\{
$usprocf @@cargs

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = c
        movsd   xmm3, qword [rsp + 24]          ; xmm3 = d
   .enter:
        @@.fld.xmm1                             ; st0 = b
        @@.fld.xmm0                             ; st0 = a | st1 = b
        @@.fld.xmm3                             ; st0 = d
        @@.fld.xmm2                             ; st0 = c | st1 = d | st2 = a | st3 = b
        fpatan
        @@.fstp.xmm1                            ; xmm1 = arg_2
        fpatan
        @@.fstp.xmm0                            ; xmm0 = arg_1
   .return:
        retn
$endp
\}
}

macro @@cargs.fpu
{
$usprocf @@cargs

        fld     qword [rsp]                     ; load a
        fld     qword [rsp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
        fxch                                    ; st0 = a | st1 = b
        fpatan                                  ; st0 = arg_1
        fld     qword [rsp + 24]                ; load d
        fld     qword [rsp + 16]                ; load c
        fpatan                                  ; st0 = arg_2 | st1 = arg_1
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cargs.sse
$else
  @@cargs.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; complex conjugate of z
; z = a + i•b
; cconj(a,b) = a + i•(-b)
;
; rsp + 0 = a
; rsp + 8 = b
;
; return_1 = st1 = a' =  a
; return_2 = st0 = b' = -b

macro @@cconj.sse
{
$usprocf @@cconj

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   xmm2, xmm1
        xorpd   xmm1, xmm1
        subsd   xmm1, xmm2                      ; xmm1 = 0-b
   .return:
        retn
$endp
}

macro @@cconj.fpu
{
$usprocf @@cconj

        fld     qword [rsp]                     ; load a
        fld     qword [rsp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b | st1 = a
        fchs
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cconj.sse
$else
  @@cconj.fpu
$end

; ------------------------------------------------------------------------------

; complex reversed conjugate of z
; z = a + i•b
; crconj(a,b) = (-a) + i•b
;
; rsp + 0 = a
; rsp + 8 = b
;
; return_1 = st1 = a' = -a
; return_2 = st0 = b' =  b

macro @@crconj.sse
{
$usprocf @@crconj

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   xmm2, xmm0
        xorpd   xmm0, xmm0
        subsd   xmm0, xmm2                      ; xmm0 = 0-a
   .return:
        retn
$endp
}

macro @@crconj.fpu
{
$usprocf @@crconj

        fld     qword [rsp]                     ; load a
        fld     qword [rsp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b | st1 = a
        fxch
        fchs
        fxch
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@crconj.sse
$else
  @@crconj.fpu
$end

; ------------------------------------------------------------------------------

; change sign of z
; z = a + i•b
; cchs(a,b) = (-a) + i•(-b)
;
; rsp + 0 = a
; rsp + 8 = b
;
; return_1 = st1 = a' = -a
; return_2 = st0 = b' = -b

macro @@cchs.sse
{
$usprocf @@cchs

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   xmm2, xmm0
        movsd   xmm3, xmm1
        xorpd   xmm0, xmm0
        xorpd   xmm1, xmm1
        subsd   xmm0, xmm2                      ; xmm0 = 0-a
        subsd   xmm1, xmm3                      ; xmm1 = 0-b
   .return:
        retn
$endp
}

macro @@cchs.fpu
{
$usprocf @@cchs

        fld     qword [rsp]                     ; load a
        fld     qword [rsp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b  | st1 = a
        fchs                                    ; st0 = -b
        fxch                                    ; st0 = a
        fchs                                    ; st0 = -a
        fxch                                    ; st0 = -b | st1 = -a
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cchs.sse
$else
  @@cchs.fpu
$end

; ------------------------------------------------------------------------------

; complex exchange
; z = a + i•b
; cxch(a,b) = (b,a)
;
; rsp + 0 = a
; rsp + 8 = b
;
; return_1 = st1 = b
; return_2 = st0 = a

macro @@cxch.sse
{
$usprocf @@cxch

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.xch  xmm0, xmm1
   .return:
        retn
$endp
}

macro @@cxch.fpu
{
$usprocf @@cxch

        fld     qword [rsp]                     ; load a
        fld     qword [rsp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b | st1 = a
        fxch                                    ; st0 = a | st1 = b
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cxch.sse
$else
  @@cxch.fpu
$end

; ------------------------------------------------------------------------------

; cos + i•sin
; ccis(x) = cos(x) + i•sin(x)
;
; rsp = x
;
; return_1 = st1 = cos(x)
; return_2 = st0 = sin(x)

macro @@ccis.sse
{
$usprocf @@ccis

        movsd   xmm0, qword [rsp]               ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     rdx, @@fcossin.enter
        call    rdx
   .return:
        retn
$endp

macro @@.ccis.fpu
\{
$usprocf @@ccis

        movsd   xmm0, qword [rsp]               ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0                             ; st0 = x
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos(x) | st1 = sin(x)
        @@.fstp.xmm0                            ; xmm0 = cos(x)
        @@.fstp.xmm1                            ; xmm1 = sin(x)
   .return:
        retn
$endp
\}
}

macro @@ccis.fpu
{
$usprocf @@ccis

        fld     qword [rsp]                     ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = x
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos(x) | st1 = sin(x)
        fxch                                    ; st0 = sin(x) | st1 = cos(x)
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@ccis.sse
$else
  @@ccis.fpu
$end

; ------------------------------------------------------------------------------

; complex sign (normalized direction)
; csign(z) = z/|z|
;
; rsp + 0 = a
; rsp + 8 = b
;
; return_1 = st1 = a' = a/r
; return_2 = st0 = b' = b/r
; r = (a^2 + b^2)^(1/2)

macro @@csign.sse
{
$usprocf @@csign

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   xmm2, xmm0
        movsd   xmm3, xmm1
        mov     rdx, @@cabs.enter
        call    rdx                             ; xmm0 = r
   .r.test:
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare r to 0
        jnz    .r.nz                            ; jump if r<>0
        jp     .r.nz                            ; jump if r<>0
   .r.z:                                        ; r=0
        xorpd   xmm0, xmm0
        xorpd   xmm1, xmm1
        jmp    .return
   .r.nz:                                       ; r<>0
        divsd   xmm2, xmm0
        divsd   xmm3, xmm0
        movsd   xmm0, xmm2
        movsd   xmm1, xmm3
   .return:
        retn
$endp
}

macro @@csign.fpu
{
$usprocf @@csign

        fld     qword [rsp]                     ; load a
        fld     qword [rsp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b   | st1 = a
        fld     st1                             ; st0 = a   | st1 = b   | st2 = a
        fld     st1                             ; st0 = b   | st1 = a   | st2 = b | st3 = a
        mov     rdx, @@cabs.enter
        call    rdx                             ; st0 = r   | st1 = b   | st2 = a
   .r.test:
        fldz                                    ; st0 = 0   | st1 = r   | st2 = b | st3 = a
        fcomp                                   ; compare 0 to r
        fnjnz  .r.nz                            ; jump if r<>0
   .r.z:                                        ; r=0
        fstp    st0
        fstp    st0
        fstp    st0
        fldz
        fldz
        jmp    .return
   .r.nz:                                       ; r<>0
        fdiv    st2, st0                        ; st0 = r   | st1 = b   | st2 = a'
        fdivp                                   ; st0 = b'  | st1 = a'
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@csign.sse
$else
  @@csign.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; complex projection on the Riemann sphere (diameter = 1)
; S: xi^2 + et^2 + (zt - 1/2)^2 = 1/4
;
; z = x + i•y
; cprojd(x,y) = (xi,et,zt)
;
; rsp + 0 = x
; rsp + 8 = y
;
; return_1 = st2 = xi = x/(r^2 + 1)
; return_2 = st1 = et = y/(r^2 + 1)
; return_3 = st0 = zt = (r^2)/(r^2 + 1)
;
; r^2 = x^2 + y^2

macro @@cprojd.sse
{
$usprocf @@cprojd

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   xmm2, xmm0
        movsd   xmm3, xmm1
        mulsd   xmm2, xmm2
        mulsd   xmm3, xmm3
        addsd   xmm2, xmm3                      ; xmm2 = r^2
        xmovsd  xmm3, ??.1.0                    ; xmm3 = 1
        movsd   xmm4, xmm3                      ; xmm4 = 1
        addsd   xmm3, xmm2                      ; xmm3 = r^2+1
        divsd   xmm4, xmm3                      ; xmm4 = 1/(r^2+1)
        mulsd   xmm0, xmm4
        mulsd   xmm1, xmm4
        mulsd   xmm2, xmm4
   .return:
        retn
$endp
}

macro @@cprojd.fpu
{
$usprocf @@cprojd

        fld     qword [rsp]                     ; load x
        fld     qword [rsp + 8]                 ; load y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = y         | st1 = x
        fld     st1
        fmul    st0, st0                        ; st0 = x^2       | st1 = y   | st2 = x
        fld     st1
        fmul    st0, st0                        ; st0 = y^2       | st1 = x^2 | st2 = y  | st3 = x
        faddp                                   ; st0 = r^2       | st1 = y   | st2 = x
        fld     st0                             ; st0 = r^2       | st1 = r^2 | st2 = y  | st3 = x
        fld1
        faddp                                   ; st0 = r^2+1     | st1 = r^2 | st2 = y  | st3 = x
        fld1
        fdivrp                                  ; st0 = 1/(r^2+1) | st1 = r^2 | st2 = y  | st3 = x
        fmul    st3, st0                        ; st0 = 1/(r^2+1) | st1 = r^2 | st2 = y  | st3 = xi
        fmul    st2, st0                        ; st0 = 1/(r^2+1) | st1 = r^2 | st2 = et | st3 = xi
        fmulp                                   ; st0 = zt        | st1 = et  | st2 = xi
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cprojd.sse
$else
  @@cprojd.fpu
$end

; ------------------------------------------------------------------------------

; complex projection on the Riemann sphere (diameter = D)
; S: xi^2 + et^2 + (zt - D/2)^2 = (D/2)^2
;
; z = x + i•y
; cprojdx(x,y,D) = (xi,et,zt)
;
; rsp + 0  = x
; rsp + 8  = y
; rsp + 16 = D
;
; return_1 = st2 = xi = x*(D^2)/(u^2)
; return_2 = st1 = et = y*(D^2)/(u^2)
; return_3 = st0 = zt = D*(r^2)/(u^2)
;
; r^2 = x^2 + y^2
; u^2 = r^2 + D^2

macro @@cprojdx.sse
{
$usprocf @@cprojdx

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = D
   .enter:
   .D.test:
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm2, xmm5                      ; compare D to 0
        jnz    .D.nz                            ; jump if D<>0
        jp     .D.nz                            ; jump if D<>0
   .D.z:                                        ; D=0
        xorpd   xmm0, xmm0
        xorpd   xmm1, xmm1
        xorpd   xmm2, xmm2
        jmp    .return
   .D.nz:                                       ; D<>0
        movsd   xmm3, xmm0
        movsd   xmm4, xmm1
        mulsd   xmm3, xmm3
        mulsd   xmm4, xmm4
        addsd   xmm3, xmm4                      ; xmm3 = r^2
        movsd   xmm4, xmm2
        mulsd   xmm4, xmm4                      ; xmm4 = D^2
        movsd   xmm5, xmm4
        addsd   xmm5, xmm3                      ; xmm5 = u^2
        xmovsd  xmm6, ??.1.0                    ; xmm6 = 1
        divsd   xmm6, xmm5                      ; xmm6 = 1/(u^2)
        mulsd   xmm4, xmm6                      ; xmm4 = (D^2)/(u^2)
        mulsd   xmm3, xmm6                      ; xmm3 = (r^2)/(u^2)
        mulsd   xmm0, xmm4
        mulsd   xmm1, xmm4
        mulsd   xmm2, xmm3
   .return:
        retn
$endp
}

macro @@cprojdx.fpu
{
$usprocf @@cprojdx

        fld     qword [rsp]                     ; load x
        fld     qword [rsp + 8]                 ; load y
        fld     qword [rsp + 16]                ; load D
   .enter:                                      ; st0 = D           | st1 = y           | st2 = x
   .D.test:
        fldz                                    ; st0 = 0           | st1 = D           | st2 = y       | st3 = x
        fcomp                                   ; compare 0 to D
        fnjnz  .D.nz                            ; jump if D<>0
   .D.z:                                        ; D=0
        fstp    st0                             ; st0 = D           | st1 = y           | st2 = x
        fstp    st0
        fstp    st0
        fldz
        fldz
        fldz
        jmp    .return
   .D.nz:                                       ; D<>0
        fld     st0                             ; st0 = D           | st1 = D           | st2 = y       | st3 = x
        fmul    st0, st0                        ; st0 = D^2         | st1 = D           | st2 = y       | st3 = x
        fld     st0                             ; st0 = D^2         | st1 = D^2         | st2 = D       | st3 = y       | st4 = x
        fld     st4
        fmul    st0, st0                        ; st0 = x^2         | st1 = D^2         | st2 = D^2     | st3 = D       | st4 = y | st5 = x
        fld     st4
        fmul    st0, st0                        ; st0 = y^2         | st1 = x^2         | st2 = D^2     | st3 = D^2     | st4 = D | st5 = y | st6 = x
        faddp                                   ; st0 = r^2         | st1 = D^2         | st2 = D^2     | st3 = D       | st4 = y | st5 = x
        fld     st0                             ; st0 = r^2         | st1 = r^2         | st2 = D^2     | st3 = D^2     | st4 = D | st5 = y | st6 = x
        fxch    st2                             ; st0 = D^2         | st1 = r^2         | st2 = r^2     | st3 = D^2     | st4 = D | st5 = y | st6 = x
        faddp                                   ; st0 = u^2         | st1 = r^2         | st2 = D^2     | st3 = D       | st4 = y | st5 = x
        fld1
        fdivrp                                  ; st0 = 1/(u^2)     | st1 = r^2         | st2 = D^2     | st3 = D       | st4 = y | st5 = x
        fmul    st3, st0                        ; st0 = 1/(u^2)     | st1 = r^2         | st2 = D^2     | st3 = D/(u^2) | st4 = y | st5 = x
        fmulp   st2, st0                        ; st0 = r^2         | st1 = (D^2)/(u^2) | st2 = D/(u^2) | st3 = y       | st4 = x
        fmulp   st2, st0                        ; st0 = (D^2)/(u^2) | st1 = zt          | st2 = y       | st3 = x
        fmul    st3, st0                        ; st0 = (D^2)/(u^2) | st1 = zt          | st2 = y       | st3 = xi
        fmulp   st2, st0                        ; st0 = zt          | st1 = et          | st2 = xi
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cprojdx.sse
$else
  @@cprojdx.fpu
$end

; ------------------------------------------------------------------------------

; complex projection on the Riemann sphere (radius = 1)
; S: xi^2 + et^2 + zt^2 = 1
;
; z = x + i•y
; cprojr(x,y) = (xi,et,zt)
;
; rsp + 0 = x
; rsp + 8 = y
;
; return_1 = st2 = xi = x*2/(u^2)
; return_2 = st1 = et = y*2/(u^2)
; return_3 = st0 = zt = (p^2)/(u^2)
;
; r^2 = x^2 + y^2
; u^2 = r^2 + 1
; p^2 = r^2 - 1

macro @@cprojr.sse
{
$usprocf @@cprojr

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   xmm2, xmm0
        movsd   xmm3, xmm1
        mulsd   xmm2, xmm2
        mulsd   xmm3, xmm3
        addsd   xmm2, xmm3                      ; xmm2 = r^2
        movsd   xmm3, xmm2                      ; xmm3 = r^2
        xmovsd  xmm4, ??.1.0                    ; xmm4 = 1
        subsd   xmm2, xmm4                      ; xmm2 = p^2
        addsd   xmm3, xmm4                      ; xmm4 = u^2
        divsd   xmm4, xmm3                      ; xmm4 = 1/(u^2)
        mulsd   xmm2, xmm4
        addsd   xmm4, xmm4                      ; xmm4 = 2/(u^2)
        mulsd   xmm0, xmm4
        mulsd   xmm1, xmm4
   .return:
        retn
$endp
}

macro @@cprojr.fpu
{
$usprocf @@cprojr

        fld     qword [rsp]                     ; load x
        fld     qword [rsp + 8]                 ; load y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = y       | st1 = x
        fld1                                    ; st0 = 1       | st1 = y       | st2 = x
        fld     st2
        fmul    st0, st0                        ; st0 = x^2     | st1 = 1       | st2 = y       | st3 = x
        fld     st2
        fmul    st0, st0                        ; st0 = y^2     | st1 = x^2     | st2 = 1       | st3 = y       | st4 = x
        faddp                                   ; st0 = r^2     | st1 = 1       | st2 = y       | st3 = x
        fsubr   st1, st0                        ; st0 = r^2     | st1 = p^2     | st2 = y       | st3 = x
        fld1
        faddp                                   ; st0 = u^2     | st1 = p^2     | st2 = y       | st3 = x
        fld1
        fdivrp                                  ; st0 = 1/(u^2) | st1 = p^2     | st2 = y       | st3 = x
        fmul    st1, st0                        ; st0 = 1/(u^2) | st1 = zt      | st2 = y       | st3 = x
        fadd    st0, st0                        ; st0 = 2/(u^2) | st1 = zt      | st2 = y       | st3 = x
        fmul    st3, st0                        ; st0 = 2/(u^2) | st1 = zt      | st2 = y       | st3 = xi
        fmulp   st2, st0                        ; st0 = zt      | st2 = et      | st3 = xi
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cprojr.sse
$else
  @@cprojr.fpu
$end

; ------------------------------------------------------------------------------

; complex projection on the Riemann sphere (radius = R)
; S: xi^2 + et^2 + zt^2 = R^2
;
; z = x + i•y
; cprojrx(x,y,R) = (xi,et,zt)
;
; rsp + 0  = x
; rsp + 8  = y
; rsp + 16 = R
;
; return_1 = st2 = xi = x*2*(R^2)/(u^2)
; return_2 = st1 = et = y*2*(R^2)/(u^2)
; return_3 = st0 = zt = R*(p^2)/(u^2)
;
; r^2 = x^2 + y^2
; u^2 = r^2 + R^2
; p^2 = r^2 - R^2

macro @@cprojrx.sse
{
$usprocf @@cprojrx

        movsd   xmm0, qword [rsp]               ; xmm0 = x
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = y
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = R
   .enter:
   .R.test:
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm2, xmm5                      ; compare R to 0
        jnz    .R.nz                            ; jump if R<>0
        jp     .R.nz                            ; jump if R<>0
   .R.z:                                        ; R=0
        xorpd   xmm0, xmm0
        xorpd   xmm1, xmm1
        xorpd   xmm2, xmm2
        jmp    .return
   .R.nz:                                       ; R<>0
        movsd   xmm3, xmm0
        movsd   xmm4, xmm1
        mulsd   xmm3, xmm3
        mulsd   xmm4, xmm4
        addsd   xmm3, xmm4                      ; xmm3 = r^2
        movsd   xmm4, xmm2
        mulsd   xmm4, xmm4                      ; xmm4 = R^2
        movsd   xmm5, xmm3                      ; xmm5 = r^2
        addsd   xmm3, xmm4                      ; xmm3 = u^2
        subsd   xmm5, xmm4                      ; xmm5 = p^2
        xmovsd  xmm6, ??.1.0                    ; xmm6 = 1
        divsd   xmm6, xmm3                      ; xmm6 = 1/(u^2)
        mulsd   xmm5, xmm6                      ; xmm5 = (p^2)/(u^2)
        mulsd   xmm4, xmm6                      ; xmm4 = (R^2)/(u^2)
        addsd   xmm4, xmm4                      ; xmm4 = 2*(R^2)/(u^2)
        mulsd   xmm0, xmm4
        mulsd   xmm1, xmm4
        mulsd   xmm2, xmm5
   .return:
        retn
$endp
}

macro @@cprojrx.fpu
{
$usprocf @@cprojrx

        fld     qword [rsp]                     ; load x
        fld     qword [rsp + 8]                 ; load y
        fld     qword [rsp + 16]                ; load R
   .enter:                                      ; st0 = R             | st1 = y       | st2 = x
   .R.test:
        fldz                                    ; st0 = 0             | st1 = R       | st2 = y       | st3 = x
        fcomp                                   ; compare 0 to R
        fnjnz  .R.nz                            ; jump if R<>0
   .R.z:                                        ; R=0
        fstp    st0                             ; st0 = R             | st1 = y       | st2 = x
        fstp    st0
        fstp    st0
        fldz
        fldz
        fldz
        jmp    .return
   .R.nz:                                       ; R<>0
        fld     st0                             ; st0 = R             | st1 = R       | st2 = y       | st3 = x
        fmul    st0, st0                        ; st0 = R^2           | st1 = R       | st2 = y       | st3 = x
        fld     st0                             ; st0 = R^2           | st1 = R^2     | st2 = R       | st3 = y   | st4 = x
        fld     st4
        fmul    st0, st0                        ; st0 = x^2           | st1 = R^2     | st2 = R^2     | st3 = R   | st4 = y | st5 = x
        fld     st4
        fmul    st0, st0                        ; st0 = y^2           | st1 = x^2     | st2 = R^2     | st3 = R^2 | st4 = R | st5 = y | st6 = x
        faddp                                   ; st0 = r^2           | st1 = R^2     | st2 = R^2     | st3 = R   | st4 = y | st5 = x
        fld     st0                             ; st0 = r^2           | st1 = r^2     | st2 = R^2     | st3 = R^2 | st4 = R | st5 = y | st6 = x
        fxch    st2                             ; st0 = R^2           | st1 = r^2     | st2 = r^2     | st3 = R^2 | st4 = R | st5 = y | st6 = x
        faddp                                   ; st0 = u^2           | st1 = r^2     | st2 = R^2     | st3 = R   | st4 = y | st5 = x
        fld1
        fdivrp                                  ; st0 = 1/(u^2)       | st1 = r^2     | st2 = R^2     | st3 = R   | st4 = y | st5 = x
        fxch                                    ; st0 = r^2           | st1 = 1/(u^2) | st2 = R^2     | st3 = R   | st4 = y | st5 = x
        fsub    st0, st2                        ; st0 = p^2           | st1 = 1/(u^2) | st2 = R^2     | st3 = R   | st4 = y | st5 = x
        fmulp   st3, st0                        ; st0 = 1/(u^2)       | st1 = R^2     | st2 = R*(p^2) | st3 = y   | st4 = x
        fmul    st2, st0                        ; st0 = 1/(u^2)       | st1 = R^2     | st2 = zt      | st3 = y   | st4 = x
        fmulp                                   ; st0 = (R^2)/(u^2)   | st1 = zt      | st2 = y       | st3 = x
        fadd    st0, st0                        ; st0 = 2*(R^2)/(u^2) | st1 = zt      | st2 = y       | st3 = x
        fmul    st3, st0                        ; st0 = 2*(R^2)/(u^2) | st1 = zt      | st2 = y       | st3 = xi
        fmulp   st2, st0                        ; st0 = zt            | st2 = et      | st3 = xi
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cprojrx.sse
$else
  @@cprojrx.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; complex plane from projection on the Riemann sphere (diameter = 1)
; S: xi^2 + et^2 + (zt - 1/2)^2 = 1/4
;
; z = x + i•y
; caprojd(xi,et,zt) = (x,y)
;
; rsp + 0  = xi
; rsp + 8  = et
; rsp + 16 = zt
;
; return_1 = st1 = x = xi/(1 - zt)
; return_2 = st0 = y = et/(1 - zt)

macro @@caprojd.sse
{
$usprocf @@caprojd

        movsd   xmm0, qword [rsp]               ; xmm0 = xi
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = et
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = zt
   .enter:
        xmovsd  xmm3, ??.1.0
        movsd   xmm4, xmm3
        subsd   xmm3, xmm2                      ; xmm3 = 1-zt
        divsd   xmm4, xmm3                      ; xmm4 = 1/(1-zt)
        mulsd   xmm0, xmm4
        mulsd   xmm1, xmm4
   .return:
        retn
$endp
}

macro @@caprojd.fpu
{
$usprocf @@caprojd

        fld     qword [rsp]                     ; load xi
        fld     qword [rsp + 8]                 ; load et
        fld     qword [rsp + 16]                ; load zt
   .enter:                                      ; st0 = zt       | st1 = et | st2 = xi
        fld1
        fsubrp                                  ; st0 = 1-zt     | st1 = et | st2 = xi
        fld1
        fdivrp                                  ; st0 = 1/(1-zt) | st1 = et | st2 = xi
        fmul    st2, st0                        ; st0 = 1/(1-zt) | st1 = et | st2 = x
        fmulp                                   ; st0 = y        | st1 = x
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@caprojd.sse
$else
  @@caprojd.fpu
$end

; ------------------------------------------------------------------------------

; complex plane from projection on the Riemann sphere (diameter = D)
; S: xi^2 + et^2 + (zt - D/2)^2 = (D/2)^2
;
; z = x + i•y
; caprojdx(xi,et,zt,D) = (x,y)
;
; rsp + 0  = xi
; rsp + 8  = et
; rsp + 16 = zt
; rsp + 24 = D
;
; return_1 = st1 = x = xi*D/(D - zt)
; return_2 = st0 = y = et*D/(D - zt)

macro @@caprojdx.sse
{
$usprocf @@caprojdx

        movsd   xmm0, qword [rsp]               ; xmm0 = xi
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = et
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = zt
        movsd   xmm3, qword [rsp + 24]          ; xmm3 = D
   .enter:
        movsd   xmm4, xmm3
        subsd   xmm4, xmm2                      ; xmm4 = D-zt
        divsd   xmm3, xmm4                      ; xmm3 = D/(D-zt)
        mulsd   xmm0, xmm3
        mulsd   xmm1, xmm3
   .return:
        retn
$endp
}

macro @@caprojdx.fpu
{
$usprocf @@caprojdx

        fld     qword [rsp]                     ; load xi
        fld     qword [rsp + 8]                 ; load et
        fld     qword [rsp + 16]                ; load zt
        fld     qword [rsp + 24]                ; load D
   .enter:                                      ; st0 = D        | st1 = zt   | st2 = et | st3 = xi
        fld     st0                             ; st0 = D        | st1 = D    | st2 = zt | st3 = et | st4 = xi
        fsubrp  st2, st0                        ; st0 = D        | st1 = D-zt | st2 = et | st3 = xi
        fdivrp                                  ; st0 = D/(D-zt) | st1 = et   | st2 = xi
        fmul    st2, st0                        ; st0 = D/(D-zt) | st1 = et   | st2 = x
        fmulp                                   ; st0 = y        | st1 = x
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@caprojdx.sse
$else
  @@caprojdx.fpu
$end

; ------------------------------------------------------------------------------

; complex plane from projection on the Riemann sphere (radius = 1)
; S: xi^2 + et^2 + zt^2 = 1
;
; z = x + i•y
; caprojr(xi,et,zt) = (x,y)
;
; rsp + 0  = xi
; rsp + 8  = et
; rsp + 16 = zt
;
; return_1 = st1 = x = xi/(1 - zt)
; return_2 = st0 = y = et/(1 - zt)

macro @@caprojr.sse
{
$usprocf @@caprojr

        movsd   xmm0, qword [rsp]               ; xmm0 = xi
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = et
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = zt
   .enter:
        xmovsd  xmm3, ??.1.0
        movsd   xmm4, xmm3
        subsd   xmm3, xmm2                      ; xmm3 = 1-zt
        divsd   xmm4, xmm3                      ; xmm4 = 1/(1-zt)
        mulsd   xmm0, xmm4
        mulsd   xmm1, xmm4
   .return:
        retn
$endp
}

macro @@caprojr.fpu
{
$usprocf @@caprojr

        fld     qword [rsp]                     ; load xi
        fld     qword [rsp + 8]                 ; load et
        fld     qword [rsp + 16]                ; load zt
   .enter:                                      ; st0 = zt       | st1 = et | st2 = xi
        fld1
        fsubrp                                  ; st0 = 1-zt     | st1 = et | st2 = xi
        fld1
        fdivrp                                  ; st0 = 1/(1-zt) | st1 = et | st2 = xi
        fmul    st2, st0                        ; st0 = 1/(1-zt) | st1 = et | st2 = x
        fmulp                                   ; st0 = y        | st1 = x
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@caprojr.sse
$else
  @@caprojr.fpu
$end

; ------------------------------------------------------------------------------

; complex plane from projection on the Riemann sphere (radius = R)
; S: xi^2 + et^2 + zt^2 = R^2
;
; z = x + i•y
; caprojrx(xi,et,zt,R) = (x,y)
;
; rsp + 0  = xi
; rsp + 8  = et
; rsp + 16 = zt
; rsp + 24 = R
;
; return_1 = st1 = x = xi*R/(R - zt)
; return_2 = st0 = y = et*R/(R - zt)

macro @@caprojrx.sse
{
$usprocf @@caprojrx

        movsd   xmm0, qword [rsp]               ; xmm0 = xi
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = et
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = zt
        movsd   xmm3, qword [rsp + 24]          ; xmm3 = R
   .enter:
        movsd   xmm4, xmm3
        subsd   xmm4, xmm2                      ; xmm4 = R-zt
        divsd   xmm3, xmm4                      ; xmm3 = R/(R-zt)
        mulsd   xmm0, xmm3
        mulsd   xmm1, xmm3
   .return:
        retn
$endp
}

macro @@caprojrx.fpu
{
$usprocf @@caprojrx

        fld     qword [rsp]                     ; load xi
        fld     qword [rsp + 8]                 ; load et
        fld     qword [rsp + 16]                ; load zt
        fld     qword [rsp + 24]                ; load R
   .enter:                                      ; st0 = R        | st1 = zt   | st2 = et | st3 = xi
        fld     st0                             ; st0 = R        | st1 = R    | st2 = zt | st3 = et | st4 = xi
        fsubrp  st2, st0                        ; st0 = R        | st1 = R-zt | st2 = et | st3 = xi
        fdivrp                                  ; st0 = R/(R-zt) | st1 = et   | st2 = xi
        fmul    st2, st0                        ; st0 = R/(R-zt) | st1 = et   | st2 = x
        fmulp                                   ; st0 = y        | st1 = x
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@caprojrx.sse
$else
  @@caprojrx.fpu
$end

; ------------------------------------------------------------------------------
