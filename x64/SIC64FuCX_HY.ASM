
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (complex number hyperbolic functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; complex hyperbolic sine
; z = a + i•b
; csinh(a,b)
; csinh(z) = sinh(a)*cos(b) + i•cosh(a)*sin(b)
;
; rsp + 0 = a
; rsp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'
;
; a' = sinh(a)*cos(b)
; b' = cosh(a)*sin(b)

macro @@csinh.sse
{
$usprocf @@csinh

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movapd  xmm3, xmm1                      ; xmm3 = b
        mov     rdx, @@fshch.enter
        call    rdx                             ; xmm0 = sinh(a) | xmm1 = cosh(a)
        @@.xch  xmm3, xmm0                      ; xmm0 = b       | xmm3 = sinh(a)
        movapd  xmm2, xmm1                      ; xmm2 = cosh(a)
        mov     rdx, @@fcossin.enter
        call    rdx                             ; xmm0 = cos(b)  | xmm1 = sin(b)
        mulsd   xmm0, xmm3                      ; xmm0 = sinh(a)*cos(b)
        mulsd   xmm1, xmm2                      ; xmm1 = cosh(a)*sin(b)
   .return:
        retn
$endp

macro @@.csinh.fpu
\{
$usprocf @@csinh

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b      | st1 = a
        ;
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos(b) | st1 = sin(b) | st2 = a
        fxch    st2                             ; st0 = a      | st1 = sin(b) | st2 = cos(b)
        mov     rdx, @@chsh.enter.fpu
        call    rdx                             ; st0 = sh(a)  | st1 = ch(a)  | st2 = sin(b) | st3 = cos(b)
        fmulp   st3, st0                        ; st0 = ch(a)  | st1 = sin(b) | st2 = sh(a)cos(b)
        fmulp                                   ; st0 = ch(a)sin(b) | st1 = sh(a)cos(b)
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
\}

$asprocf @@csinh.enter.fpu
                                                ; st0 = b      | st1 = a
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos(b) | st1 = sin(b) | st2 = a
        fxch    st2                             ; st0 = a      | st1 = sin(b) | st2 = cos(b)
        mov     rdx, @@chsh.enter.fpu
        call    rdx                             ; st0 = sh(a)  | st1 = ch(a)  | st2 = sin(b) | st3 = cos(b)
        fmulp   st3, st0                        ; st0 = ch(a)  | st1 = sin(b) | st2 = sh(a)cos(b)
        fmulp                                   ; st0 = ch(a)sin(b) | st1 = sh(a)cos(b)
   .return:
        retn
$endp
}

macro @@csinh.fpu
{
$usprocf @@csinh

        fld     qword [rsp]                     ; load a
        fld     qword [rsp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b      | st1 = a
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos(b) | st1 = sin(b) | st2 = a
        fxch    st2                             ; st0 = a      | st1 = sin(b) | st2 = cos(b)
        mov     rdx, @@chsh.enter
        call    rdx                             ; st0 = sh(a)  | st1 = ch(a)  | st2 = sin(b) | st3 = cos(b)
        fmulp   st3, st0                        ; st0 = ch(a)  | st1 = sin(b) | st2 = sh(a)cos(b)
        fmulp                                   ; st0 = ch(a)sin(b) | st1 = sh(a)cos(b)
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@csinh.sse
$else
  @@csinh.fpu
$end

; ------------------------------------------------------------------------------

; complex hyperbolic cosine
; z = a + i•b
; ccosh(a,b)
; ccosh(z) = cosh(a)*cos(b) + i•sinh(a)*sin(b)
;
; rsp + 0 = a
; rsp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'
;
; a' = cosh(a)*cos(b)
; b' = sinh(a)*sin(b)

macro @@ccosh.sse
{
$usprocf @@ccosh

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movapd  xmm3, xmm1                      ; xmm3 = b
        mov     rdx, @@fshch.enter
        call    rdx                             ; xmm0 = sinh(a) | xmm1 = cosh(a)
        @@.xch  xmm3, xmm0                      ; xmm0 = b       | xmm3 = sinh(a)
        movapd  xmm2, xmm1                      ; xmm2 = cosh(a)
        mov     rdx, @@fcossin.enter
        call    rdx                             ; xmm0 = cos(b)  | xmm1 = sin(b)
        mulsd   xmm0, xmm2                      ; xmm0 = cosh(a)*cos(b)
        mulsd   xmm1, xmm3                      ; xmm1 = sinh(a)*sin(b)
   .return:
        retn
$endp

macro @@.ccosh.fpu
\{
$usprocf @@ccosh

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b      | st1 = a
        ;
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos(b) | st1 = sin(b) | st2 = a
        fxch    st2                             ; st0 = a      | st1 = sin(b) | st2 = cos(b)
        mov     rdx, @@shch.enter.fpu
        call    rdx                             ; st0 = ch(a)  | st1 = sh(a)  | st2 = sin(b) | st3 = cos(b)
        fmulp   st3, st0                        ; st0 = sh(a)  | st1 = sin(b) | st2 = ch(a)cos(b)
        fmulp                                   ; st0 = sh(a)sin(b) | st1 = ch(a)cos(b)
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
\}

$asprocf @@ccosh.enter.fpu
                                                ; st0 = b      | st1 = a
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos(b) | st1 = sin(b) | st2 = a
        fxch    st2                             ; st0 = a      | st1 = sin(b) | st2 = cos(b)
        mov     rdx, @@shch.enter.fpu
        call    rdx                             ; st0 = ch(a)  | st1 = sh(a)  | st2 = sin(b) | st3 = cos(b)
        fmulp   st3, st0                        ; st0 = sh(a)  | st1 = sin(b) | st2 = ch(a)cos(b)
        fmulp                                   ; st0 = sh(a)sin(b) | st1 = ch(a)cos(b)
   .return:
        retn
$endp
}

macro @@ccosh.fpu
{
$usprocf @@ccosh

        fld     qword [rsp]                     ; load a
        fld     qword [rsp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b      | st1 = a
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos(b) | st1 = sin(b) | st2 = a
        fxch    st2                             ; st0 = a      | st1 = sin(b) | st2 = cos(b)
        mov     rdx, @@shch.enter
        call    rdx                             ; st0 = ch(a)  | st1 = sh(a)  | st2 = sin(b) | st3 = cos(b)
        fmulp   st3, st0                        ; st0 = sh(a)  | st1 = sin(b) | st2 = ch(a)cos(b)
        fmulp                                   ; st0 = sh(a)sin(b) | st1 = ch(a)cos(b)
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@ccosh.sse
$else
  @@ccosh.fpu
$end

; ------------------------------------------------------------------------------

; complex hyperbolic secant
; z = a + i•b
; csech(a,b) = 1/ccosh(a,b)
;
; rsp + 0 = a
; rsp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@csech.sse
{
$usprocf @@csech

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     rdx, @@ccosh.enter
        call    rdx
        mov     rdx, @@cinv.enter
        call    rdx
   .return:
        retn
$endp

macro @@.csech.fpu
\{
$usprocf @@csech

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b | st1 = a
        ;
        mov     rdx, @@ccosh.enter.fpu
        call    rdx
        mov     rdx, @@cinv.enter.fpu
        call    rdx
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
\}
}

macro @@csech.fpu
{
$usprocf @@csech

        fld     qword [rsp]                     ; load a
        fld     qword [rsp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b | st1 = a
        mov     rdx, @@ccosh.enter
        call    rdx
        mov     rdx, @@cinv.enter
        call    rdx
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@csech.sse
$else
  @@csech.fpu
$end

; ------------------------------------------------------------------------------

; complex hyperbolic cosecant
; z = a + i•b
; ccosech(a,b) = 1/csinh(a,b)
;
; rsp + 0 = a
; rsp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@ccosech.sse
{
$usprocf @@ccosech

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     rdx, @@csinh.enter
        call    rdx
        mov     rdx, @@cinv.enter
        call    rdx
   .return:
        retn
$endp

macro @@.ccosech.fpu
\{
$usprocf @@ccosech

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b | st1 = a
        ;
        mov     rdx, @@csinh.enter.fpu
        call    rdx
        mov     rdx, @@cinv.enter.fpu
        call    rdx
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
\}
}

macro @@ccosech.fpu
{
$usprocf @@ccosech

        fld     qword [rsp]                     ; load a
        fld     qword [rsp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b | st1 = a
        mov     rdx, @@csinh.enter
        call    rdx
        mov     rdx, @@cinv.enter
        call    rdx
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@ccosech.sse
$else
  @@ccosech.fpu
$end

; ------------------------------------------------------------------------------

; complex hyperbolic tangent
; z = a + i•b
; ctanh(a,b) = csinh(a,b) / ccosh(a,b)
;
; rsp + 0 = a
; rsp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@ctanh.sse
{
$usprocf @@ctanh

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movapd  xmm6, xmm0
        movapd  xmm7, xmm1
        mov     rdx, @@ccosh.enter
        call    rdx
        @@.xch  xmm6, xmm0
        @@.xch  xmm7, xmm1
        mov     rdx, @@csinh.enter
        call    rdx
        movapd  xmm2, xmm6
        movapd  xmm3, xmm7
        mov     rdx, @@cdiv.enter
        call    rdx
   .return:
        retn
$endp

macro @@.ctanh.fpu
\{
$usprocf @@ctanh

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b      | st1 = a
        ;
        fld     st1
        fld     st1                             ; st0 = b      | st1 = a      | st2 = b      | st3 = a
        mov     rdx, @@ccosh.enter.fpu
        call    rdx                             ; st0 = ccos.b | st1 = ccos.a | st2 = b      | st3 = a
        fxch    st2                             ; st0 = b      | st1 = ccos.a | st2 = ccos.b | st3 = a
        fxch                                    ; st0 = ccos.a | st1 = b      | st2 = ccos.b | st3 = a
        fxch    st3                             ; st0 = a      | st1 = b      | st2 = ccos.b | st3 = ccos.a
        fxch                                    ; st0 = b      | st1 = a      | st2 = ccos.b | st3 = ccos.a
        mov     rdx, @@csinh.enter.fpu
        call    rdx                             ; st0 = csin.b | st1 = csin.a | st2 = ccos.b | st3 = ccos.a
        mov     rdx, @@cdivr.enter.fpu
        call    rdx
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
\}
}

macro @@ctanh.fpu
{
$usprocf @@ctanh

        fld     qword [rsp]                     ; load a
        fld     qword [rsp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b      | st1 = a
        fld     st1
        fld     st1                             ; st0 = b      | st1 = a      | st2 = b      | st3 = a
        mov     rdx, @@ccosh.enter
        call    rdx                             ; st0 = ccos.b | st1 = ccos.a | st2 = b      | st3 = a
        fxch    st2                             ; st0 = b      | st1 = ccos.a | st2 = ccos.b | st3 = a
        fxch                                    ; st0 = ccos.a | st1 = b      | st2 = ccos.b | st3 = a
        fxch    st3                             ; st0 = a      | st1 = b      | st2 = ccos.b | st3 = ccos.a
        fxch                                    ; st0 = b      | st1 = a      | st2 = ccos.b | st3 = ccos.a
        mov     rdx, @@csinh.enter
        call    rdx                             ; st0 = csin.b | st1 = csin.a | st2 = ccos.b | st3 = ccos.a
        mov     rdx, @@cdivr.enter
        call    rdx
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@ctanh.sse
$else
  @@ctanh.fpu
$end

; ------------------------------------------------------------------------------

; complex hyperbolic cotangent
; z = a + i•b
; ccotanh(a,b) = ccosh(a,b) / csinh(a,b)
;
; rsp + 0 = a
; rsp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@ccotanh.sse
{
$usprocf @@ccotanh

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movapd  xmm6, xmm0
        movapd  xmm7, xmm1
        mov     rdx, @@csinh.enter
        call    rdx
        @@.xch  xmm6, xmm0
        @@.xch  xmm7, xmm1
        mov     rdx, @@ccosh.enter
        call    rdx
        movapd  xmm2, xmm6
        movapd  xmm3, xmm7
        mov     rdx, @@cdiv.enter
        call    rdx
   .return:
        retn
$endp

macro @@.ccotanh.fpu
\{
$usprocf @@ccotanh

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b      | st1 = a
        ;
        fld     st1
        fld     st1                             ; st0 = b      | st1 = a      | st2 = b      | st3 = a
        mov     rdx, @@ccosh.enter.fpu
        call    rdx                             ; st0 = ccos.b | st1 = ccos.a | st2 = b      | st3 = a
        fxch    st2                             ; st0 = b      | st1 = ccos.a | st2 = ccos.b | st3 = a
        fxch                                    ; st0 = ccos.a | st1 = b      | st2 = ccos.b | st3 = a
        fxch    st3                             ; st0 = a      | st1 = b      | st2 = ccos.b | st3 = ccos.a
        fxch                                    ; st0 = b      | st1 = a      | st2 = ccos.b | st3 = ccos.a
        mov     rdx, @@csinh.enter.fpu
        call    rdx                             ; st0 = csin.b | st1 = csin.a | st2 = ccos.b | st3 = ccos.a
        mov     rdx, @@cdiv.enter.fpu
        call    rdx
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
\}
}

macro @@ccotanh.fpu
{
$usprocf @@ccotanh

        fld     qword [rsp]                     ; load a
        fld     qword [rsp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b      | st1 = a
        fld     st1
        fld     st1                             ; st0 = b      | st1 = a      | st2 = b      | st3 = a
        mov     rdx, @@ccosh.enter
        call    rdx                             ; st0 = ccos.b | st1 = ccos.a | st2 = b      | st3 = a
        fxch    st2                             ; st0 = b      | st1 = ccos.a | st2 = ccos.b | st3 = a
        fxch                                    ; st0 = ccos.a | st1 = b      | st2 = ccos.b | st3 = a
        fxch    st3                             ; st0 = a      | st1 = b      | st2 = ccos.b | st3 = ccos.a
        fxch                                    ; st0 = b      | st1 = a      | st2 = ccos.b | st3 = ccos.a
        mov     rdx, @@csinh.enter
        call    rdx                             ; st0 = csin.b | st1 = csin.a | st2 = ccos.b | st3 = ccos.a
        mov     rdx, @@cdiv.enter
        call    rdx
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@ccotanh.sse
$else
  @@ccotanh.fpu
$end

; ------------------------------------------------------------------------------

; inverse complex hyperbolic sine
; z = a + i•b
; casinh(z)
; ln(z + (z^2 + 1)^(1/2))
;
; rsp + 0 = a
; rsp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@casinh.sse.fpu
{
$usprocf @@casinh

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b | st1 = a
        ;
        fld     st1
        fld     st1                             ; st0 = b | st1 = a | st2 = b | st3 = a
        mov     rdx, @@cpow2.enter.fpu
        call    rdx                             ; st0:st1 = z^2
        fld1
        faddp   st2, st0                        ; z^2+1
        mov     rdx, @@croot2.enter.fpu
        call    rdx                             ; (z^2+1)^(1/2)
        mov     rdx, @@cadd.enter.fpu
        call    rdx                             ; z+(z^2+1)^(1/2)
        mov     rdx, @@cln.enter.fpu
        call    rdx                             ; ln(z+(z^2+1)^(1/2))
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
}

macro @@casinh.fpu
{
$usprocf @@casinh

        fld     qword [rsp]                     ; load a
        fld     qword [rsp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b | st1 = a
        fld     st1
        fld     st1                             ; st0 = b | st1 = a | st2 = b | st3 = a
        mov     rdx, @@cpow2.enter
        call    rdx                             ; st0:st1 = z^2
        fld1
        faddp   st2, st0                        ; z^2+1
        mov     rdx, @@croot2.enter
        call    rdx                             ; (z^2+1)^(1/2)
        mov     rdx, @@cadd.enter
        call    rdx                             ; z+(z^2+1)^(1/2)
        mov     rdx, @@cln.enter
        call    rdx                             ; ln(z+(z^2+1)^(1/2))
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@casinh.sse.fpu
$else
  @@casinh.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; inverse complex hyperbolic cosine
; z = a + i•b
; cacosh(z)
; ln(z + (z^2 - 1)^(1/2))
;
; rsp + 0 = a
; rsp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@cacosh.sse.fpu
{
$usprocf @@cacosh

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b | st1 = a
        ;
        fld     st1
        fld     st1                             ; st0 = b | st1 = a | st2 = b | st3 = a
        mov     rdx, @@cpow2.enter.fpu
        call    rdx                             ; st0:st1 = z^2
        fld1
        fsubp   st2, st0                        ; z^2-1
        mov     rdx, @@croot2.enter.fpu
        call    rdx                             ; (z^2-1)^(1/2)
        mov     rdx, @@cadd.enter.fpu
        call    rdx                             ; z+(z^2-1)^(1/2)
        mov     rdx, @@cln.enter.fpu
        call    rdx                             ; ln(z+(z^2-1)^(1/2))
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
}

macro @@cacosh.fpu
{
$usprocf @@cacosh

        fld     qword [rsp]                     ; load a
        fld     qword [rsp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b | st1 = a
        fld     st1
        fld     st1                             ; st0 = b | st1 = a | st2 = b | st3 = a
        mov     rdx, @@cpow2.enter
        call    rdx                             ; st0:st1 = z^2
        fld1
        fsubp   st2, st0                        ; z^2-1
        mov     rdx, @@croot2.enter
        call    rdx                             ; (z^2-1)^(1/2)
        mov     rdx, @@cadd.enter
        call    rdx                             ; z+(z^2-1)^(1/2)
        mov     rdx, @@cln.enter
        call    rdx                             ; ln(z+(z^2-1)^(1/2))
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cacosh.sse.fpu
$else
  @@cacosh.fpu
$end

; ------------------------------------------------------------------------------

; inverse complex hyperbolic secant
; z = a + i•b
; casech(z) = cacosh(1/z)
;
; rsp + 0 = a
; rsp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@casech.sse.fpu
{
$usprocf @@casech

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b | st1 = a
        ;
        mov     rdx, @@cinv.enter.fpu
        call    rdx                             ; 1/z
   .cacosh:
        fld     st1
        fld     st1                             ; st0 = b | st1 = a | st2 = b | st3 = a
        mov     rdx, @@cpow2.enter.fpu
        call    rdx                             ; st0:st1 = z^2
        fld1
        fsubp   st2, st0                        ; z^2-1
        mov     rdx, @@croot2.enter.fpu
        call    rdx                             ; (z^2-1)^(1/2)
        mov     rdx, @@cadd.enter.fpu
        call    rdx                             ; z+(z^2-1)^(1/2)
        mov     rdx, @@cln.enter.fpu
        call    rdx                             ; ln(z+(z^2-1)^(1/2))
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
}

macro @@casech.fpu
{
$usprocf @@casech

        fld     qword [rsp]                     ; load a
        fld     qword [rsp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b | st1 = a
        mov     rdx, @@cinv.enter
        call    rdx                             ; 1/z
   .cacosh:
        fld     st1
        fld     st1                             ; st0 = b | st1 = a | st2 = b | st3 = a
        mov     rdx, @@cpow2.enter
        call    rdx                             ; st0:st1 = z^2
        fld1
        fsubp   st2, st0                        ; z^2-1
        mov     rdx, @@croot2.enter
        call    rdx                             ; (z^2-1)^(1/2)
        mov     rdx, @@cadd.enter
        call    rdx                             ; z+(z^2-1)^(1/2)
        mov     rdx, @@cln.enter
        call    rdx                             ; ln(z+(z^2-1)^(1/2))
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@casech.sse.fpu
$else
  @@casech.fpu
$end

; ------------------------------------------------------------------------------

; inverse complex hyperbolic cosecant
; z = a + i•b
; cacosech(z) = casinh(1/z)
;
; rsp + 0 = a
; rsp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@cacosech.sse.fpu
{
$usprocf @@cacosech

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b | st1 = a
        ;
        mov     rdx, @@cinv.enter.fpu
        call    rdx                             ; 1/z
   .casinh:
        fld     st1
        fld     st1                             ; st0 = b | st1 = a | st2 = b | st3 = a
        mov     rdx, @@cpow2.enter.fpu
        call    rdx                             ; st0:st1 = z^2
        fld1
        faddp   st2, st0                        ; z^2+1
        mov     rdx, @@croot2.enter.fpu
        call    rdx                             ; (z^2+1)^(1/2)
        mov     rdx, @@cadd.enter.fpu
        call    rdx                             ; z+(z^2+1)^(1/2)
        mov     rdx, @@cln.enter.fpu
        call    rdx                             ; ln(z+(z^2+1)^(1/2))
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
}

macro @@cacosech.fpu
{
$usprocf @@cacosech

        fld     qword [rsp]                     ; load a
        fld     qword [rsp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b | st1 = a
        mov     rdx, @@cinv.enter
        call    rdx                             ; 1/z
   .casinh:
        fld     st1
        fld     st1                             ; st0 = b | st1 = a | st2 = b | st3 = a
        mov     rdx, @@cpow2.enter
        call    rdx                             ; st0:st1 = z^2
        fld1
        faddp   st2, st0                        ; z^2+1
        mov     rdx, @@croot2.enter
        call    rdx                             ; (z^2+1)^(1/2)
        mov     rdx, @@cadd.enter
        call    rdx                             ; z+(z^2+1)^(1/2)
        mov     rdx, @@cln.enter
        call    rdx                             ; ln(z+(z^2+1)^(1/2))
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cacosech.sse.fpu
$else
  @@cacosech.fpu
$end

; ------------------------------------------------------------------------------

; inverse complex hyperbolic tangent
; z = a + i•b
; catanh(z)
; (1/2)*ln((1+z)/(1-z))
;
; rsp + 0 = a
; rsp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@catanh.sse.fpu
{
$usprocf @@catanh

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b | st1 = a
        ;
        fld     st1
        fld     st1
        fchs                                    ; st0:st1 = ~z | st2:st3 = z
                                                ; ~z = (-i•b+a)
        fld1                                    ; st0 = 1 | st1:st2 = ~z | st3:st4 = z
        fadd    st4, st0                        ; st0 = 1 | st1:st2 = ~z | st3:st4 = 1+z
        fsubrp  st2, st0                        ; st0:st1 = 1-z | st2:st3 = 1+z
        mov     rdx, @@cdiv.enter.fpu
        call    rdx                             ; (1+z)/(1-z)
        mov     rdx, @@cln.enter.fpu
        call    rdx                             ; ln((1+z)/(1-z))
        fldq    ??.0.5
        fmul    st2, st0
        fmulp                                   ; (1/2)*ln((1+z)/(1-z))
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
}

macro @@catanh.fpu
{
$usprocf @@catanh

        fld     qword [rsp]                     ; load a
        fld     qword [rsp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b | st1 = a
        fld     st1
        fld     st1
        fchs                                    ; st0:st1 = ~z | st2:st3 = z
                                                ; ~z = (-i•b+a)
        fld1                                    ; st0 = 1 | st1:st2 = ~z | st3:st4 = z
        fadd    st4, st0                        ; st0 = 1 | st1:st2 = ~z | st3:st4 = 1+z
        fsubrp  st2, st0                        ; st0:st1 = 1-z | st2:st3 = 1+z
        mov     rdx, @@cdiv.enter
        call    rdx                             ; (1+z)/(1-z)
        mov     rdx, @@cln.enter
        call    rdx                             ; ln((1+z)/(1-z))
        fldq    ??.0.5
        fmul    st2, st0
        fmulp                                   ; (1/2)*ln((1+z)/(1-z))
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@catanh.sse.fpu
$else
  @@catanh.fpu
$end

; ------------------------------------------------------------------------------

; inverse complex hyperbolic cotangent
; z = a + i•b
; cacotanh(z)
; (1/2)*ln((z+1)/(z-1))
;
; rsp + 0 = a
; rsp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@cacotanh.sse.fpu
{
$usprocf @@cacotanh

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b | st1 = a
        ;
        fld     st1
        fld     st1                             ; st0:st1 = z | st2:st3 = z
        fld1                                    ; st0 = 1 | st1:st2 = z | st3:st4 = z
        fadd    st4, st0                        ; st0 = 1 | st1:st2 = z | st3:st4 = z+1
        fsubp   st2, st0                        ; st0:st1 = z-1 | st2:st3 = z+1
        mov     rdx, @@cdiv.enter.fpu
        call    rdx                             ; (z+1)/(z-1)
        mov     rdx, @@cln.enter.fpu
        call    rdx                             ; ln((z+1)/(z-1))
        fldq    ??.0.5
        fmul    st2, st0
        fmulp                                   ; (1/2)*ln((z+1)/(z-1))
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
}

macro @@cacotanh.fpu
{
$usprocf @@cacotanh

        fld     qword [rsp]                     ; load a
        fld     qword [rsp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b | st1 = a
        fld     st1
        fld     st1                             ; st0:st1 = z | st2:st3 = z
        fld1                                    ; st0 = 1 | st1:st2 = z | st3:st4 = z
        fadd    st4, st0                        ; st0 = 1 | st1:st2 = z | st3:st4 = z+1
        fsubp   st2, st0                        ; st0:st1 = z-1 | st2:st3 = z+1
        mov     rdx, @@cdiv.enter
        call    rdx                             ; (z+1)/(z-1)
        mov     rdx, @@cln.enter
        call    rdx                             ; ln((z+1)/(z-1))
        fldq    ??.0.5
        fmul    st2, st0
        fmulp                                   ; (1/2)*ln((z+1)/(z-1))
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cacotanh.sse.fpu
$else
  @@cacotanh.fpu
$end

; ------------------------------------------------------------------------------
